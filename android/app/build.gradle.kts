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
            signingConfig = if (hasReleaseSigning) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
            ndk { abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64", "x86") }
        }
        named("release") {
            // 有发布密钥用正式签名；否则回退 debug 签名（对齐 moneyfly 的做法）。
            // 以前这里写成 else null → release APK **完全没有签名**（v1/v2/v3 全无），
            // 华为手机安装时报「解析包出现问题」。debug 签名在 CI 上是固定的
            // (~/.android/debug.keystore + 固定密码 android)，所以回退它也能覆盖升级。
            signingConfig = if (hasReleaseSigning) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
            ndk {
                abiFilters.clear()
                abiFilters += listOf("armeabi-v7a", "arm64-v8a")
            }
        }
    }

    // 多 ABI 分版本：三档 APK + universal。
    //
    // ⚠️ 构建 AAB 时必须关掉：AGP 的 bundleRelease 在 splits 打开时会在
    // build/app/intermediates/shrunk_resources_proto_format/.../ 下发现多个
    // shrunk-resources 文件并直接失败
    // （「Multiple shrunk-resources files found ... Please disable building multiple
    //   APKs when building an Android app bundle」，issuetracker 402800800）。
    // 应用商店的 AAB 本来就要求单一产物，所以由 CI 传
    // `ORG_GRADLE_PROJECT_disableAbiSplits=true`（Gradle 会自动映射为项目属性），
    // 本地默认行为不变。
    splits {
        abi {
            isEnable = !project.hasProperty("disableAbiSplits")
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
    // 位置是 packages/libclash_vpn_service/android/libs/libmihomo.aar
    // （实测该 AAR：classes.jar 含 top.moneyfly.mihomelib.Mihomelib + go.*，
    //   jni 下 arm64-v8a / armeabi-v7a / x86 / x86_64 各一个 libgojni.so，
    //   共 177MB —— 所以"只放一份"很关键）。
    //
    // 这里原先还有一段 `implementation(files("libs/libmihomo.aar"))`，
    // 并在缺失时打印「请下载到 android/app/libs/」。那是个陷阱：
    // 一旦真按提示放了一份，同一份 AAR 就会被链接两次 →
    //   · duplicate class：AAR 里的 go.Seq / go.Universe /
    //     top.moneyfly.mihomelib.Mihomelib 会被链接两次
    //   · 原生库冲突：AAR 的 .so 名是 **libgojni.so**（gomobile 的固定名字），
    //     打包时四套 ABI 目录下都会出现同路径文件
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
