import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

var dartEnvironmentVariables = mutableMapOf("publish" to false)

if (project.hasProperty("dart-defines")) {
    dartEnvironmentVariables.putAll(
            (project.property("dart-defines") as String).split(',').associate { entry ->
                val pair = String(Base64.getDecoder().decode(entry)).split('=')
                pair.first() to (pair.last() == "true")
            }
    )
}

// ============================================================================
// 签名：一律从环境变量读取，**绝不入库任何密钥**。
//   KEYSTORE_BASE64     release.keystore 的 base64（CI Secret；本地可缺省）
//   KEYSTORE_PASSWORD / KEY_ALIAS / KEY_PASSWORD
// 缺失时回退 debug 签名并打印醒目警告 —— 回退签名只用于本地开发，
// 用它出正式包会导致版本间签名不一致 → 用户无法覆盖升级、必须卸载重装。
//
// 注意：**不能**在配置阶段无条件读取密钥文件。旧实现（Mclash）
// 直接 key.properties.inputStream() 且路径指向不存在的文件，
// 会让**所有** buildType（含 debug）在配置期就失败。
// ============================================================================
val keystoreBase64: String? = System.getenv("KEYSTORE_BASE64")?.takeIf { it.isNotBlank() }
val keystorePassword: String? = System.getenv("KEYSTORE_PASSWORD")?.takeIf { it.isNotBlank() }
val keyAliasValue: String? = System.getenv("KEY_ALIAS")?.takeIf { it.isNotBlank() }
val keyPasswordValue: String? = System.getenv("KEY_PASSWORD")?.takeIf { it.isNotBlank() }

val hasReleaseSigning: Boolean =
        keystoreBase64 != null &&
                keystorePassword != null &&
                keyAliasValue != null &&
                keyPasswordValue != null

// 把 base64 密钥解码到 build/ 下的临时文件（不入库，构建结束可丢弃）
val decodedKeystore = layout.buildDirectory.file("keystore/release.keystore").get().asFile
if (hasReleaseSigning && !decodedKeystore.exists()) {
    decodedKeystore.parentFile.mkdirs()
    decodedKeystore.writeBytes(Base64.getDecoder().decode(keystoreBase64))
}

android {
    namespace = "top.moneyfly.mclash"
    compileSdkVersion = "android-35"
    buildToolsVersion = "36.0.0"
    ndkVersion = "28.2.13676358" // flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }

    defaultConfig {
        applicationId = "top.moneyfly.mclash"
        minSdk = 26
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = decodedKeystore
                storePassword = keystorePassword
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    buildTypes {
        named("debug") {
            ndk { abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64", "x86") }
        }
        named("profile") {
            signingConfig = if (hasReleaseSigning) signingConfigs.getByName("release") else null
            ndk { abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64", "x86") }
        }
        named("release") {
            signingConfig = if (hasReleaseSigning) signingConfigs.getByName("release") else null
            ndk {
                abiFilters.clear()
                abiFilters += listOf("armeabi-v7a", "arm64-v8a")
            }
        }
    }

    // 多 ABI 分版本：三档 APK + universal
    splits {
        abi {
            isEnable = true
            isUniversalApk = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86_64")
        }
    }

    packaging {
        jniLibs {
            // 内核 .so 由 libmihomo.aar 提供；release 去掉 x86_64 以省体积
            useLegacyPackaging = true
        }
    }
}

androidComponents {
    onVariants { variant ->
        if (variant.buildType == "release") {
            variant.packaging.jniLibs.excludes.add("**/x86_64/**")
        }
    }
}

flutter { source = "../.." }

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.browser:browser:1.8.0")

    // ---------------------------------------------------------------------
    // mihomo 内核：libmihomo.aar
    //   来源 github.com/moneyfly004/mihomo-lib（官方 MetaCubeX/mihomo 源码 +
    //   gomobile bind，无 fork）。CI 直接下载，本地用 tool/build_mihomo_aar.sh 现编。
    //   缺失时构建**不会失败**，但连接会不可用 —— 由 Dart 侧在
    //   KernelManager.detectCurrent() 里给出明确提示。
    // ---------------------------------------------------------------------
    val aar = file("libs/libmihomo.aar")
    if (aar.exists()) {
        implementation(files(aar))
    } else {
        logger.warn(
                "[Mclash] android/app/libs/libmihomo.aar 不存在 —— " +
                        "内置内核不可用（VpnService 无法启动）。请先下载：\n" +
                        "  curl -fL -o android/app/libs/libmihomo.aar \\\n" +
                        "    https://github.com/moneyfly004/mihomo-lib/releases/download/v1.19.30/libmihomo.aar"
        )
    }
}

configurations.configureEach {
    resolutionStrategy.force(
            "androidx.browser:browser:1.8.0",
            "androidx.core:core:1.15.0",
            "androidx.core:core-ktx:1.15.0",
            "androidx.activity:activity:1.9.3",
            "androidx.activity:activity-ktx:1.9.3",
    )
}

// 正式包缺签名时给醒目提示（不中断构建，方便 CI 先跑通）
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any { it.name.contains("Release") }
    if (buildingRelease && !hasReleaseSigning) {
        logger.warn(
                "\n[Mclash] 未提供发布签名（KEYSTORE_BASE64 / KEYSTORE_PASSWORD / KEY_ALIAS / KEY_PASSWORD），" +
                        "\n         release 包将使用 debug 签名 —— 仅可用于本地验证，不可分发。\n"
        )
    }
}
