// Top-level build file
plugins {
    id("com.android.application") version "8.4.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.1" apply false
}

val kotlinVersion = "2.1.0"
val gradleVersion = "8.4.1"
val desugarVersion = "2.0.4"

buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        if (
            project.plugins.hasPlugin("com.android.application") ||
            project.plugins.hasPlugin("com.android.library")
        ) {
            project.dependencies.add("coreLibraryDesugaring", "com.android.tools:desugar_jdk_libs:$desugarVersion")
        }
    }
}
