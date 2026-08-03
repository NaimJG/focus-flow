plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ncambe.focus_flow"
    // Google Play requires targetSdk/compileSdk ≥ 36 (August 2025 deadline).
    // Override Flutter-managed values only if they resolve below 36;
    // once Flutter bumps past 36 this becomes a no-op.
    compileSdk = if ((flutter.compileSdkVersion as Int) >= 36) flutter.compileSdkVersion else 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ncambe.focus_flow"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = if ((flutter.targetSdkVersion as Int) >= 36) flutter.targetSdkVersion else 36
        // Version mapping from pubspec.yaml (version: 1.0.0+1):
        //   "1.0.0" → versionName (displayed to users on Google Play)
        //   "1"     → versionCode (internal version number for Google Play)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
