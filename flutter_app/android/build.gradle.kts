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

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    val injectNamespace = Action<Project> {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt is com.android.build.gradle.LibraryExtension) {
                if (androidExt.namespace.isNullOrEmpty()) {
                    androidExt.namespace = project.group.toString().ifEmpty { "com.razorpay.${project.name}" }
                }
            }
        }
    }
    if (project.state.executed) {
        injectNamespace.execute(this)
    } else {
        project.afterEvaluate(injectNamespace)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
