plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.benjsant.candid"
    // 37 et non flutter.compileSdkVersion (36) : receive_sharing_intent exige
    // de compiler contre l'API 37. N'affecte que la compilation, pas le
    // comportement à l'exécution (targetSdk reste celui de Flutter).
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Exigé par flutter_local_notifications : il utilise des API de date
        // du JDK que minSdk 24 n'a pas. Le desugaring les fournit à la
        // compilation, sans relever minSdk (ce qui exclurait des appareils).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.benjsant.candid"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // R8 supprime ce qu'il croit mort. Or WorkManager et Room passent
            // par la réflexion : sans ces règles, l'application compile puis
            // plante au lancement (voir proguard-rules.pro pour la trace).
            // Un build debug ne le montre jamais, il n'est pas minifié.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
