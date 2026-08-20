/// Collecte quotidienne en arrière-plan, via `workmanager`.
///
/// **Avertissement à garder en tête** (PLAN, « pièges connus ») : Android
/// exécute ces tâches en théorie, mais ColorOS, MIUI et One UI tuent
/// agressivement les processus d'arrière-plan. Selon l'appareil et les réglages
/// de batterie, la collecte peut ne jamais partir. C'est pour ça qu'elle arrive
/// en dernier et que le bouton « Collecter » reste la voie fiable :
/// l'application doit rester pleinement utilisable sans cette tâche.
///
/// La tâche tourne dans un **isolat séparé**, qui ne partage rien avec
/// l'interface : ni base ouverte, ni coffre-fort, ni client HTTP. Tout est
/// reconstruit ici, puis refermé : une base laissée ouverte verrouillerait le
/// fichier pour l'application principale.
library;

import 'package:workmanager/workmanager.dart';

import '../core/notifications.dart';
import '../core/secrets.dart';
import '../data/database.dart';
import '../data/digest_service.dart';
import '../data/offers_repository.dart';
import '../sources/collect_service.dart';
import '../sources/france_travail.dart';
import '../sources/lba.dart';

/// Identifiants de la tâche périodique. `uniqueName` sert aussi à l'annuler.
const kCollectTaskName = 'candid-collecte-quotidienne';
const kCollectTaskUnique = 'candid-collecte-quotidienne';

/// Tâche ponctuelle, pour vérifier que l'arrière-plan fonctionne **sur cet
/// appareil-ci**. Ce n'est pas un artifice de test : la fiabilité dépend
/// tellement du constructeur que l'utilisateur doit pouvoir s'en assurer
/// lui-même, plutôt que d'attendre un lendemain qui ne viendra peut-être pas.
const kCollectOnceName = 'candid-collecte-ponctuelle';
const kCollectOnceUnique = 'candid-collecte-ponctuelle';

/// Digest hebdomadaire : le point sur la recherche, pas sur la collecte.
const kDigestTaskName = 'candid-digest-hebdo';
const kDigestTaskUnique = 'candid-digest-hebdo';
const kDigestFrequency = Duration(days: 7);

/// Périodicité. Android impose un minimum de 15 minutes ; une fois par jour est
/// largement suffisant pour des offres d'emploi, et ménage la batterie.
const kCollectFrequency = Duration(hours: 24);

/// Point d'entrée de l'isolat de fond. Doit être une fonction de premier niveau
/// annotée `@pragma('vm:entry-point')`, sinon l'arbre de compilation la retire
/// en release et la tâche échoue silencieusement.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kDigestTaskName) return runDigestInBackground();
    if (task != kCollectTaskName && task != kCollectOnceName) return true;
    return runCollectInBackground();
  });
}

/// Le travail réel. Rend `true` si la tâche est considérée comme faite :
/// Android ne la replanifiera pas immédiatement. On rend `false` uniquement
/// quand un nouvel essai a des chances d'aboutir (panne réseau).
@pragma('vm:entry-point')
Future<bool> runCollectInBackground() async {
  final db = AppDatabase();
  try {
    final secrets = Secrets();
    final service = CollectService(
      db: db,
      repository: OffersRepository(db),
      franceTravail: FranceTravailClient(secrets: secrets),
      lba: LbaClient(secrets: secrets),
    );

    final report = await service.collect();

    final message = collectNotification(
      saved: report.saved,
      notable: report.notable,
      errors: report.errors,
    );
    if (message != null) {
      final notifications = Notifications();
      await notifications.init();
      await notifications.show(message.title, message.body);
    }

    // Une source en échec n'est pas une raison de réessayer en boucle : la
    // prochaine occurrence quotidienne suffit, et la notification a prévenu.
    return true;
  } catch (_) {
    // Échec inattendu : on demande un nouvel essai, mais sans jamais laisser
    // l'exception remonter (elle tuerait le worker sans trace exploitable).
    return false;
  } finally {
    // Indispensable : sans fermeture, le fichier SQLite reste verrouillé et
    // l'application principale ne peut plus écrire.
    await db.close();
  }
}

/// Planifie ou annule la tâche quotidienne selon la préférence.
///
/// Idempotent : `ExistingPeriodicWorkPolicy.keep` évite de réinitialiser le
/// compte à rebours à chaque démarrage de l'application, ce qui repousserait
/// indéfiniment la première exécution.
Future<void> syncDailyCollect(bool enabled) async {
  if (!enabled) {
    await Workmanager().cancelByUniqueName(kCollectTaskUnique);
    return;
  }
  await Workmanager().registerPeriodicTask(
    kCollectTaskUnique,
    kCollectTaskName,
    frequency: kCollectFrequency,
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    // Inutile de réveiller le téléphone sans réseau : la collecte échouerait.
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

/// Déclenche une collecte de fond immédiate. Sert au bouton « Tester
/// maintenant » des réglages.
Future<void> runCollectOnceInBackground() async {
  await Workmanager().registerOneOffTask(
    // Horodaté : WorkManager refuse de rejouer une tâche unique déjà connue,
    // ce qui rendrait le bouton inopérant au deuxième appui.
    '$kCollectOnceUnique-${DateTime.now().millisecondsSinceEpoch}',
    kCollectOnceName,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

/// Construit et notifie le digest hebdomadaire. Ne touche à aucune API : tout
/// se lit dans la base locale, donc pas de clé requise et pas de réseau.
@pragma('vm:entry-point')
Future<bool> runDigestInBackground() async {
  final db = AppDatabase();
  try {
    final digest = await DigestService(db).build();
    final message = digestNotification(digest);
    if (message != null) {
      final notifications = Notifications();
      await notifications.init();
      await notifications.show(message.title, message.body,
          id: kDigestNotificationId);
    }
    return true;
  } catch (_) {
    return false;
  } finally {
    await db.close();
  }
}

/// Planifie ou annule le digest hebdomadaire.
Future<void> syncWeeklyDigest(bool enabled) async {
  if (!enabled) {
    await Workmanager().cancelByUniqueName(kDigestTaskUnique);
    return;
  }
  await Workmanager().registerPeriodicTask(
    kDigestTaskUnique,
    kDigestTaskName,
    frequency: kDigestFrequency,
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    // Aucun appel réseau : le digest se calcule sur la base locale.
  );
}
