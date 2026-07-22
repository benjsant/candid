/// Notifications locales : ce qui remplace Discord côté mobile.
///
/// Une seule notification, après une collecte de fond, et seulement s'il y a
/// quelque chose à dire. Le projet Docker envoyait un message par offre
/// pertinente ; sur un téléphone, ce serait insupportable. On résume.
///
/// Rien ici n'agit à la place de l'utilisateur : la notification ouvre
/// l'application, elle ne postule pas.
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Canal Android. Le nom et la description sont visibles dans les réglages
/// système : ils doivent être compréhensibles hors contexte.
const _channelId = 'candid_collecte';
const _channelName = 'Nouvelles offres';
const _channelDescription =
    'Résumé de la collecte quotidienne : combien de nouvelles offres, et '
    'combien méritent un coup d\'œil.';

/// Identifiants de notification. Un par type de message.
const kCollectNotificationId = 1;
const kDigestNotificationId = 2;

/// Seuil au-delà duquel une offre est signalée comme intéressante. Aligné sur
/// le `score_threshold` par défaut du profil de recherche.
const kNotableScore = 75;

class Notifications {
  Notifications([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Demande la permission (Android 13+). Refusée, la collecte continue de
  /// tourner : elle sera simplement muette.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    return await android.requestNotificationsPermission() ?? false;
  }

  Future<bool> get isAllowed async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.areNotificationsEnabled() ?? false;
  }

  Future<void> show(String title, String body,
      {int id = kCollectNotificationId}) async {
    await _plugin.show(
      // Identifiant fixe par type : un nouveau résumé remplace le précédent au
      // lieu d'empiler des notifications périmées. Le digest a le sien, pour ne
      // pas écraser le bilan de collecte du matin.
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }
}

/// Le texte de la notification, à partir du bilan d'une collecte.
///
/// Rend `null` quand il n'y a rien à dire : une notification « 0 nouvelle
/// offre » chaque matin ferait désinstaller l'application. Fonction pure, donc
/// testable sans plugin.
({String title, String body})? collectNotification({
  required int saved,
  required int notable,
  List<String> errors = const [],
}) {
  if (saved == 0) {
    // Une panne persistante mérite un mot, sinon l'utilisateur croit que la
    // collecte tourne alors qu'elle échoue tous les jours en silence.
    if (errors.isEmpty) return null;
    return (
      title: 'Collecte interrompue',
      body: errors.first,
    );
  }

  final offres = saved > 1 ? '$saved nouvelles offres' : '1 nouvelle offre';
  final body = notable > 0
      ? (notable > 1
          ? '$notable dépassent $kNotableScore/100.'
          : '1 dépasse $kNotableScore/100.')
      : 'Aucune ne dépasse $kNotableScore/100.';
  return (title: offres, body: body);
}
