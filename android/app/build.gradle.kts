plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.prayer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // START FIX: Mengaktifkan Core Library Desugaring
    compileOptions {
        // Mengubah ke Java 1.8 (Java 8) untuk Desugaring
        sourceCompatibility = JavaVersion.VERSION_1_8 
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true // BARIS KUNCI 1
    }

    kotlinOptions {
        // Sesuaikan jvmTarget ke 1.8
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }
    // END FIX

    defaultConfig {
        applicationId = "com.example.prayer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// BARIS KUNCI 2: Tambahkan blok dependencies di akhir file
dependencies {
    // Tambahkan dependensi Desugaring untuk mendukung fitur Java 8+ pada Android lama
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}