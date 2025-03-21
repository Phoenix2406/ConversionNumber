pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")

// Force Gradle to use the correct shared_preferences_android path
val sharedPreferencesPath = file(System.getProperty("user.home") + "/.pub-cache/hosted/pub.dev/shared_preferences_android-2.4.8/android")

if (sharedPreferencesPath.exists()) {
    include(":shared_preferences_android")
    project(":shared_preferences_android").projectDir = sharedPreferencesPath
}