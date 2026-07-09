import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val admobProperties = Properties()
val admobPropertiesFile = rootProject.file("admob.properties")
if (admobPropertiesFile.exists()) {
    admobPropertiesFile.inputStream().use { admobProperties.load(it) }
}

android {
    namespace = "com.appsbay.classic_15_puzzle"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.appsbay.classic_15_puzzle"
        minSdk = 24
        targetSdk = 35
        versionCode = localProperties.getProperty("flutter.versionCode")?.toInt() ?: 1
        versionName = localProperties.getProperty("flutter.versionName") ?: "1.0"
        multiDexEnabled = true
    }

    buildFeatures {
        buildConfig = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            
            val appId = admobProperties.getProperty("AdMobAppId") ?: "ca-app-pub-3940256099942544~3347511713"
            manifestPlaceholders["AdMobAppId"] = appId
            buildConfigField("String", "AD_BANNER_UNIT_ID", "\"${admobProperties.getProperty("AdBannerUnitId") ?: ""}\"")
            buildConfigField("String", "AD_OPEN_UNIT_ID", "\"${admobProperties.getProperty("AdOpenUnitId") ?: ""}\"")
            buildConfigField("String", "AD_INTERSTITIAL_UNIT_ID", "\"${admobProperties.getProperty("AdInterstitialUnitId") ?: ""}\"")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
            
            manifestPlaceholders["AdMobAppId"] = "ca-app-pub-3940256099942544~3347511713"
            buildConfigField("String", "AD_BANNER_UNIT_ID", "\"ca-app-pub-3940256099942544/6300978111\"")
            buildConfigField("String", "AD_OPEN_UNIT_ID", "\"ca-app-pub-3940256099942544/3419835294\"")
            buildConfigField("String", "AD_INTERSTITIAL_UNIT_ID", "\"ca-app-pub-3940256099942544/1033173712\"")
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

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
