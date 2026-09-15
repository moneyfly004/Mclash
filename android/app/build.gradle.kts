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
    // mihomo 内核（libmihomo.aar）**不在这里声明**。
    //
    // 内核由插件 `packages/libclash_vpn_service` 独家提供：它的
    // android/build.gradle 会把 android/libs/*.aar 加进实现依赖，
    // 并同时把 libs 加进 jniLibs.srcDirs。也就是说 AAR 只应存在一份，
    // 位置是 packages/libclash_vpn_service/android/libs/libmihomo.aar。
    //
    // 这里原先还有一段 `implementation(files("libs/libmihomo.aar"))`，
    // 并在缺失时打印「请下载到 android/app/libs/」。那是个陷阱：
    // 一旦真按提示放了一份，同一份 AAR 就会被链接两次 →
    //   · duplicate class（mobile.*、go.* 会重复）
    //   · libmihomo.so 在打包时路径冲突
    // 所以整段删除，只留这条说明，避免后人照做过时的提示。
    // ---------------------------------------------------------------------
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
