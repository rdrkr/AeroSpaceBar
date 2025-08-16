/*
 * Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
 */

rootProject.name = "AeroSpaceBar"
enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    @Suppress("UnstableApiUsage")
    repositories {
        google()
        mavenCentral()
    }
}

include(":Common")
