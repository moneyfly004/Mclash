import com.android.build.gradle.internal.crash.afterEvaluate

allprojects {
    repositories {
        google()
        mavenCentral()
        // -----------------------------------------------------------------
        // 内核 AAR（artifact 名 libmihomo）的解析仓库。
        //
        // 为什么在**根**这里也要声明一次：Gradle 的 repositories 是**按模块**
        // 生效的 —— 插件模块（:libclash_vpn_service）里那处 flatDir 只让插件
        // 自己能编译，不会传给 :app。结果是插件编译通过、打到 :app 解析
        // debugRuntimeClasspath 时报：
        //     Could not find :libmihomo:.
        //     Required by: project :app > project :libclash_vpn_service
        // 所以这里补一份，让所有模块都能解析到同一个文件。
        //
        // 目标目录就是唯一那份 AAR 的落点（已在 .gitignore 中，不入库）。
        // -----------------------------------------------------------------
        flatDir {
            dirs(rootProject.file("../packages/libclash_vpn_service/android/libs"))
        }
    }
    subprojects {
        afterEvaluate {
            if (plugins.hasPlugin("com.android.application") ||
                            plugins.hasPlugin("com.android.library")
            ) {
                extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.let {
                        androidExt ->
                    androidExt.compileSdkVersion = "android-35"
                    androidExt.ndkVersion = "28.2.13676358"

                    if (androidExt.namespace == null) {
                        androidExt.namespace = project.group.toString()
                    }

                    if (androidExt.buildFeatures.buildConfig == null) {
                        androidExt.buildFeatures.buildConfig = true
                    }

                    project
                            .fileTree(project.projectDir) { include("**/AndroidManifest.xml") }
                            .forEach { manifestFile ->
                                var manifestContent = manifestFile.readText()
                                if (manifestContent.contains("package=")) {
                                    println("Removing package attribute from ${manifestFile}")
                                    manifestContent =
                                            manifestContent.replace(Regex("package=\"[^\"]*\""), "")
                                    manifestFile.writeText(manifestContent)
                                }
                            }
                }
            }
        }
    }
}

allprojects {
    tasks.withType<JavaCompile> {
        options.compilerArgs.plusAssign("-Xlint:unchecked")
        options.compilerArgs.plusAssign("-Xlint:deprecation")
    }
}
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
