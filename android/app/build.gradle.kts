plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.finansmart.finansmart"

    // Requerido por permission_handler y flutter_local_notifications
    compileSdk = 37

    ndkVersion = flutter.ndkVersion


    compileOptions {

        sourceCompatibility = JavaVersion.VERSION_17

        targetCompatibility = JavaVersion.VERSION_17

        // Requerido para flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }


    defaultConfig {

        applicationId = "com.finansmart.finansmart"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }


    buildTypes {

        release {

            signingConfig =
                signingConfigs.getByName("debug")

        }

    }

}



kotlin {

    compilerOptions {

        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17

    }

}



dependencies {

    // Necesario para flutter_local_notifications
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )

}



flutter {

    source = "../.."

}