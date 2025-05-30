plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.intership_task"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.intership_task"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        vectorDrawables.useSupportLibrary = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Firebase BoM ensures all versions are aligned
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Firebase Messaging — no version!
    implementation("com.google.firebase:firebase-messaging")

    // Java 8+ Desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// 🔥 Force Gradle to ignore firebase-iid if it appears
configurations.all {
    resolutionStrategy.eachDependency {
        if (requested.group == "com.google.firebase" && requested.name == "firebase-iid") {
            useVersion("0.0.0") // dummy version to block it
            because("firebase-iid causes class duplication with firebase-messaging")
        }
    }
}



flutter {
    source = "../.."
}
