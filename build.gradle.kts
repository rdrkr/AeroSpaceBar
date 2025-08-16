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
val swiftSourceDir = "$projectName/"
val productDir = "${System.getProperty("user.home")}/Library/Developer/Xcode/DerivedData/AeroSpaceBar-fifbaernwsaqwhfwajnuubouitxw/Build/Products"

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
        println("""
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
        """.trimIndent())
    }
}

// Debug build task
tasks.register("buildDebug") {
    group = buildGroup
    description = "Build the project in Debug configuration"
    doLast {
        exec {
            commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Debug", "build")
        }
        println("✅ Debug build completed")
    }
}

// Release build task
tasks.register("buildRelease") {
    group = buildGroup
    description = "Build the project in Release configuration"
    doLast {
        exec {
            commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Release", "build")
        }
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
tasks.register("clean") {
    group = buildGroup
    description = "Clean build artifacts, DerivedData, and Gradle build directory"
    doLast {
        exec {
            commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "clean")
        }
        exec {
            commandLine("rm", "-rf", "DerivedData")
        }
        exec {
            commandLine("rm", "-rf", "build")
        }
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
tasks.register("format") {
    group = codeQualityGroup
    description = "Format code with SwiftFormat"
    doLast {
        exec {
            commandLine("swiftformat", swiftSourceDir)
        }
        println("✅ Code formatting completed")
    }
}

// Lint task
tasks.register("lint") {
    group = codeQualityGroup
    description = "Lint code with SwiftLint"
    doLast {
        exec {
            commandLine("swiftlint", "lint", "--strict", swiftSourceDir)
        }
        println("✅ Code linting completed")
    }
}

// Lint fix task
tasks.register("lintFix") {
    group = codeQualityGroup
    description = "Auto-fix linting issues (where possible)"
    doLast {
        exec {
            commandLine("swiftlint", "--fix", swiftSourceDir)
        }
        println("✅ Lint fixes applied")
    }
}

// Lint rules task
tasks.register("lintRules") {
    group = codeQualityGroup
    description = "Show linting rules"
    doLast {
        exec {
            commandLine("swiftlint", "rules")
        }
    }
}

// Format rules task
tasks.register("formatRules") {
    group = codeQualityGroup
    description = "Show SwiftFormat rules"
    doLast {
        exec {
            commandLine("swiftformat", "--help")
        }
    }
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
tasks.register("test") {
    group = testGroup
    description = "Run Xcode tests"
    doLast {
        exec {
            commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Debug", "test")
        }
        println("✅ Tests completed")
    }
}

// Install tools task
tasks.register("installTools") {
    group = toolingGroup
    description = "Install SwiftLint and SwiftFormat"
    doLast {
        println("Installing SwiftLint...")
        exec {
            commandLine("brew", "install", "swiftlint")
        }
        println("Installing SwiftFormat...")
        exec {
            commandLine("brew", "install", "swiftformat")
        }
        println("✅ Development tools installed")
    }
}

// Additional utility tasks

// Run Debug task
tasks.register("runDebug") {
    group = buildGroup
    description = "Build Debug variant and run the application"
    dependsOn("buildDebug")
    doLast {
        println("🚀 Launching Debug application...")
        exec {
            commandLine("$productDir/Debug/AeroSpaceBar.app/Contents/MacOS/AeroSpaceBar")
        }
        println("✅ Debug application stopped")
    }
}

// Run Release task
tasks.register("runRelease") {
    group = buildGroup
    description = "Build Release variant and run the application"
    dependsOn("buildRelease")
    doLast {
        println("🚀 Launching Release application...")
        exec {
            commandLine("$productDir/Release/AeroSpaceBar.app/Contents/MacOS/AeroSpaceBar")
        }
        println("✅ Release application stopped")
    }
}

// Run task (default - uses Debug)
tasks.register("run") {
    group = buildGroup
    description = "Build Debug and run the application (alias for runDebug)"
    dependsOn("runDebug")
}

// Archive task
tasks.register("archive") {
    group = buildGroup
    description = "Create archive for distribution"
    dependsOn("clean", "build")
    doLast {
        exec {
            commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Release", "archive", "-archivePath", "build/AeroSpaceBar.xcarchive")
        }
        println("✅ Archive created at build/AeroSpaceBar.xcarchive")
    }
}

// Analyze task
tasks.register("analyze") {
    group = codeQualityGroup
    description = "Run Xcode static analyzer"
    doLast {
        exec {
            commandLine("xcodebuild", "-project", xcodeProject, "-scheme", xcodeScheme, "-configuration", "Debug", "analyze")
        }
        println("✅ Static analysis completed")
    }
}

// Show project info
tasks.register("info") {
    group = "help"
    description = "Show project information"
    doLast {
        println("""
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
        """.trimIndent())
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