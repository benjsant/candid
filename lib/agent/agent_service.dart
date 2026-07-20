/// Orchestrateur de l'agent côté application : charge le contexte (prompt
/// système, index CV), résout le fournisseur LLM actif et sa clé, applique le
/// plafond d'appels, lance le graphe, et compte l'appel.
///
/// Se désactive proprement : sans clé, ou plafond atteint, il lève une
/// [AgentUnavailable] avec un motif lisible plutôt que de planter.
library;

import 'dart:convert';

import '../core/assets.dart';
import '../core/secrets.dart';
import 'agent_config.dart';
import 'graph.dart';
import 'llm.dart';
import 'models.dart';

/// L'agent ne peut pas tourner, avec la raison (affichée à l'utilisateur).
class AgentUnavailable implements Exception {
  AgentUnavailable(this.reason);
  final String reason;
  @override
  String toString() => reason;
}

class AgentService {
  AgentService({
    required this.secrets,
    AgentConfig? config,
    this.assets = const AppAssets(),
    this.dailyCap = kDefaultDailyCap,
  }) : config = config ?? AgentConfig();

  final Secrets secrets;
  final AgentConfig config;
  final AppAssets assets;
  final int dailyCap;

  /// Combien d'appels restent aujourd'hui (pour l'affichage « 3/5 »).
  Future<int> usedToday() => config.usedToday();

  /// Lance l'agent sur une offre. Lève [AgentUnavailable] si pas de clé ou
  /// plafond atteint.
  Future<AgentRun> generate(AgentOffer offer) async {
    final provider = await config.provider();
    final llmConfig = await resolveLlmConfig(
      secrets: secrets,
      provider: provider,
      model: await config.model(),
    );
    if (llmConfig == null) {
      throw AgentUnavailable(
          'Aucune clé pour ${provider.label}. Ajoutez-la dans les réglages.');
    }
    if (!await config.hasBudget(cap: dailyCap)) {
      throw AgentUnavailable(
          'Plafond du jour atteint ($dailyCap appels). Réessayez demain.');
    }

    final systemPrompt = await assets.systemPrompt();
    final cvIndexMap = await assets.cvIndex();
    final cvIndex = jsonEncode(cvIndexMap);

    final run = await runAgent(
      offer: offer,
      systemPrompt: systemPrompt,
      cvIndex: cvIndex,
      llm: LlmClient(llmConfig),
    );

    // On ne compte que les passages qui ont abouti (un échec réseau franc ne
    // consomme pas le budget du jour).
    if (run.error == null) await config.recordCall();
    return run;
  }
}
