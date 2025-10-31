allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix for google_mlkit packages namespace issue
subprojects {
    afterEvaluate {
        if ((project.name == "google_mlkit_commons" || 
             project.name == "google_mlkit_pose_detection" ||
             project.name == "camera_android" ||
             project.name == "flutter_plugin_android_lifecycle") && 
             project.hasProperty("android")) {
            project.android.namespace = project.android.namespace ?: project.group
        }
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
