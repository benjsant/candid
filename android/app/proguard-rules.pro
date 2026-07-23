# Règles R8 pour le build release.
#
# Contexte : le build debug n'est pas minifié, le build release l'est. Tout ce
# qui est instancié par **réflexion** est donc invisible pour R8, qui le supprime
# comme du code mort. L'application compile, puis plante au démarrage.
#
# Constaté le 23/07/2026 sur l'appareil, avec le premier build release installé :
#
#   java.lang.NoSuchMethodException: androidx.work.impl.WorkDatabase_Impl.<init> []
#       at androidx.work.WorkManagerInitializer.b(...)
#
# WorkManager s'initialise au lancement via androidx.startup et ouvre sa base
# Room. Room instancie sa classe générée `WorkDatabase_Impl` par réflexion, sur
# son constructeur sans argument : R8 l'avait retiré.

# --- Room (utilisé par WorkManager) ---
# Les classes `*_Impl` sont générées puis instanciées par réflexion. Garder le
# constructeur sans argument suffit ; inutile de garder toute la classe.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.room.RoomDatabase { *; }
-dontwarn androidx.room.paging.**

# --- WorkManager ---
# Les Workers sont instanciés par nom de classe. Celui de Candid vient du plugin
# workmanager, mais la règle couvre aussi tout Worker ajouté plus tard.
-keep class * extends androidx.work.Worker { <init>(...); }
-keep class * extends androidx.work.ListenableWorker { <init>(...); }
-keep class androidx.work.impl.** { *; }

# --- androidx.startup ---
# Les initialiseurs sont déclarés dans le manifeste et chargés par réflexion.
-keep class * extends androidx.startup.Initializer { <init>(); }

# --- Flutter et plugins ---
# Les canaux de plateforme passent par des noms de méthode ; le moteur Flutter
# gère déjà ses propres règles, on garde ici l'entrée des plugins enregistrés.
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# flutter_local_notifications sérialise ses réglages en JSON via Gson.
-keep class com.dexterous.** { *; }
-keep class * implements com.google.gson.** { *; }
-dontwarn com.google.gson.**
