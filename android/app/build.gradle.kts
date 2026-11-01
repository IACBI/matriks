import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.matrixeducator.matriks"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Shared with the iOS, macOS and Linux identifiers. It is permanent
        // once published: a store treats a different ID as another app.
        applicationId = "com.matrixeducator.matriks"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // The upload key stays with the release owner: android/key.properties and
    // the keystore it names are git-ignored and never committed. Without them a
    // release build is signed with the debug key, which no store accepts, so
    // CI and local release runs still build; see docs/YAYINLAMA.md.
    val keyProperties = Properties().apply {
        val file = rootProject.file("key.properties")
        if (file.exists()) file.inputStream().use { load(it) }
    }
    val hasUploadKey = !keyProperties.isEmpty
    fun uploadKey(name: String): String =
        keyProperties.getProperty(name)?.takeIf { it.isNotBlank() }
            ?: throw GradleException("android/key.properties has no $name")

    signingConfigs {
        if (hasUploadKey) {
            create("upload") {
                storeFile = file(uploadKey("storeFile"))
                storePassword = uploadKey("storePassword")
                keyAlias = uploadKey("keyAlias")
                keyPassword = uploadKey("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasUploadKey) "upload" else "debug")
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
