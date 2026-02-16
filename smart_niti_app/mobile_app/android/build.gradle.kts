allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// subprojects {
//     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//     project.layout.buildDirectory.value(newSubprojectBuildDir)
// }
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // --- เพิ่มส่วนนี้เพื่อแก้ปัญหา Cross-Drive (D: vs C:) ---
    afterEvaluate {
        // ตรวจสอบว่าเป็น Android Library (Plugin) หรือไม่
        if (project.plugins.hasPlugin("com.android.library")) {
            // ถ้าใช่ ให้ปิด Unit Test ทิ้งไปเลย จะได้ไม่ต้องเช็ค Path ข้ามไดรฟ์
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                testOptions {
                    unitTests.all {
                        it.enabled = false
                    }
                }
            }
        }
    }
    // ----------------------------------------------------
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
