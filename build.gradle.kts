/**
 * Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
 */

plugins {
    alias(libs.plugins.kotlinMultiplatform) apply false
}

// Project configuration
val projectName = "AeroSpaceBar"
val xcodeProject = "$projectName.xcodeproj"
val xcodeScheme = projectName
val productDir = "${System.getProperty("user.home")}/Library/Developer/Xcode/" +
        "DerivedData/AeroSpaceBar-fifbaernwsaqwhfwajnuubouitxw/Build/Products"

// Task groups for better organization
val buildGroup = "build"
val codeQualityGroup = "code quality"
val testGroup = "verification"
val toolingGroup = "tooling"

// Default task
defaultTasks("showHelp")

// Help task
tasks.register("showHelp") {
    group = "help"
    description = "Show available tasks"
    doLast {
        println(
            """
            🚀 AeroSpaceBar - Available Gradle Tasks
            
            📦 Build Tasks:
              build        - Build all variants (Debug and Release)
              buildDebug   - Build the project in Debug configuration
              buildRelease - Build the project in Release configuration
              runDebug     - Build Debug variant and run the application
              runRelease   - Build Release variant and run the application
              run          - Build Debug and run the application (alias for runDebug)
              clean        - Clean build artifacts and DerivedData
              all          - Run all checks and tests
            
            🎨 Code Quality:
              format       - Format code with SwiftFormat
              lint         - Lint code with SwiftLint
              check        - Run format and lint checks
              lintFix      - Auto-fix linting issues (where possible)
              lintRules    - Show linting rules
              formatRules  - Show SwiftFormat rules
            
            🧪 Testing:
              test         - Run Xcode tests
            
            🛠️ Tooling:
              installTools - Install SwiftLint and SwiftFormat
              showHelp     - Show this help message
            
            💡 Usage: ./gradlew <task>
            Example: ./gradlew build
        """.trimIndent()
        )
    }
}

// Debug build task
tasks.register<Exec>("buildDebug") {
    group = buildGroup
    description = "Build the project in Debug configuration"
    commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Debug", "build")
    doLast {
        println("✅ Debug build completed")
    }
}

// Release build task
tasks.register<Exec>("buildRelease") {
    group = buildGroup
    description = "Build the project in Release configuration"
    commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Release", "build")
    doLast {
        println("✅ Release build completed")
    }
}

// Main build task - builds all variants (Debug and Release)
tasks.register("build") {
    group = buildGroup
    description = "Build all variants (Debug and Release)"
    dependsOn("buildDebug", "buildRelease")
    doLast {
        println("✅ All variants built successfully")
    }
}

// Clean task
val cleanXcode = tasks.register<Exec>("cleanXcode") {
    commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "clean")
}

val cleanDerivedData = tasks.register<Exec>("cleanDerivedData") {
    commandLine("rm", "-rf", "DerivedData")
}

val cleanBuild = tasks.register<Exec>("cleanBuild") {
    commandLine("rm", "-rf", "build")
    commandLine("rm", "-rf", ".build")
}

tasks.register("clean") {
    group = buildGroup
    description = "Clean build artifacts, DerivedData, and Gradle build directory"
    dependsOn(cleanXcode, cleanDerivedData, cleanBuild)
    doLast {
        println("✅ Clean completed (Xcode + DerivedData + Gradle build)")
    }
}


// All-in-one task
tasks.register("all") {
    group = buildGroup
    description = "Run all checks and tests"
    dependsOn("clean", "check", "build") //, "test")
}

// Format task
tasks.register<Exec>("format") {
    group = codeQualityGroup
    description = "Format code with SwiftFormat"
    workingDir = projectDir
    commandLine("/opt/homebrew/bin/swiftformat", "--config", ".swiftformat", projectDir)
    doLast {
        println("✅ Code formatting completed")
    }
}

// Lint task
tasks.register<Exec>("lint") {
    group = codeQualityGroup
    description = "Lint code with SwiftLint"
    commandLine("/opt/homebrew/bin/swiftlint", "lint", "--strict")
    doLast {
        println("✅ Code linting completed")
    }
}

// Lint fix task
tasks.register<Exec>("lintFix") {
    group = codeQualityGroup
    description = "Auto-fix linting issues (where possible)"
    commandLine("/opt/homebrew/bin/swiftlint", "--fix")
    doLast {
        println("✅ Lint fixes applied")
    }
}

// Lint rules task
tasks.register<Exec>("lintRules") {
    group = codeQualityGroup
    description = "Show linting rules"
    commandLine("/opt/homebrew/bin/swiftlint", "rules")
}

// Format rules task
tasks.register<Exec>("formatRules") {
    group = codeQualityGroup
    description = "Show SwiftFormat rules"
    commandLine("/opt/homebrew/bin/swiftformat", "--help")
}

// Check task (format + lint)
tasks.register("check") {
    group = codeQualityGroup
    description = "Run format and lint checks"
    dependsOn("format", "lint")
    doLast {
        println("✅ Code formatting and linting completed")
    }
}

// Test task
tasks.register<Exec>("test") {
    group = testGroup
    description = "Run Xcode tests"
    commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Debug", "test")
    doLast {
        println("✅ Tests completed")
    }
}

// Install tools task
val installSwiftLint = tasks.register<Exec>("installSwiftLint") {
    commandLine("brew", "install", "swiftlint")
    doFirst {
        println("Installing SwiftLint...")
    }
}

val installSwiftFormat = tasks.register<Exec>("installSwiftFormat") {
    commandLine("brew", "install", "swiftformat")
    doFirst {
        println("Installing SwiftFormat...")
    }
}

tasks.register("installTools") {
    group = toolingGroup
    description = "Install SwiftLint and SwiftFormat"
    dependsOn(installSwiftLint, installSwiftFormat)
    doLast {
        println("✅ Development tools installed")
    }
}

// Additional utility tasks

// Run Debug task
val runDebugApp = tasks.register<Exec>("runDebugApp") {
    commandLine("$productDir/Debug/AeroSpaceBar.app/Contents/MacOS/AeroSpaceBar")
    doFirst {
        println("🚀 Launching Debug application...")
    }
    doLast {
        println("✅ Debug application stopped")
    }
}

tasks.register("runDebug") {
    group = buildGroup
    description = "Build Debug variant and run the application"
    dependsOn("buildDebug", runDebugApp)
}

// Run Release task
val runReleaseApp = tasks.register<Exec>("runReleaseApp") {
    commandLine("$productDir/Release/AeroSpaceBar.app/Contents/MacOS/AeroSpaceBar")
    doFirst {
        println("🚀 Launching Release application...")
    }
    doLast {
        println("✅ Release application stopped")
    }
}

tasks.register("runRelease") {
    group = buildGroup
    description = "Build Release variant and run the application"
    dependsOn("buildRelease", runReleaseApp)
}

// Run task (default - uses Debug)
tasks.register("run") {
    group = buildGroup
    description = "Build Debug and run the application (alias for runDebug)"
    dependsOn("runDebug")
}

// Archive task
tasks.register<Exec>("archive") {
    group = buildGroup
    description = "Create archive for distribution"
    dependsOn("clean", "build")
    commandLine(
        "xcodebuild",
        "-project",
        xcodeProject,
        "-scheme",
        xcodeScheme,
        "-configuration",
        "Release",
        "archive",
        "-archivePath",
        "build/AeroSpaceBar.xcarchive"
    )
    doLast {
        println("✅ Archive created at build/AeroSpaceBar.xcarchive")
    }
}

// Analyze task
tasks.register<Exec>("analyze") {
    group = codeQualityGroup
    description = "Run Xcode static analyzer"
    commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Debug", "analyze")
    doLast {
        println("✅ Static analysis completed")
    }
}

// Show project info
tasks.register("info") {
    group = "help"
    description = "Show project information"
    doLast {
        println(
            """
            📋 AeroSpaceBar Project Information
            
            🏗️ Architecture: MVVM Clean Architecture
            🎨 UI Framework: SwiftUI
            🧪 Testing: XCTest (Unit + UI Tests)
            🛠️ Build System: Gradle + Xcode
            📱 Platform: macOS 14.0+
            🚀 Swift Version: 6.2+
            
            📁 Key Directories:
              - AeroSpaceBar/        - Main application source
              - AeroSpaceBarTests/   - Unit tests
              - AeroSpaceBarUITests/ - UI tests
              - Docs/                - Documentation
            
            🔧 Configuration Files:
              - .swiftformat         - Code formatting rules
              - .swiftlint.yml       - Linting rules
              - build.gradle.kts     - This build configuration
        """.trimIndent()
        )
    }
}

// Configure task execution order
tasks.configureEach {
    when (name) {
        "lint" -> mustRunAfter("format")
        "check" -> mustRunAfter("clean")
        "build" -> mustRunAfter("check")
        "test" -> mustRunAfter("build")
    }
}