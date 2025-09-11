# 🚀 AeroSpaceBar

<div align="center">
  <img src="Docs/Assets/AeroSpaceBar-macOS-Default-512x512@1x.png" alt="AeroSpaceBar App Icon" width="128" height="128">
</div>

> **A modern macOS menu bar application for managing AeroSpace window manager spaces and windows with a beautiful
SwiftUI interface**

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%203.0-blue.svg)](https://opensource.org/licenses/AGPL-3.0)
[![Swift](https://img.shields.io/badge/Swift-6.2+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-14.0+-silver.svg)](https://www.apple.com/macos/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20Clean%20Architecture-green.svg)](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)

<div align="center">
  <img src="Docs/Assets/demo.gif" alt="Demo">
</div>

## 📖 Overview

AeroSpaceBar is a sophisticated macOS menu bar application that provides seamless integration with
the [AeroSpace window manager](https://github.com/nikitabobko/aerospace). Built with modern SwiftUI and following Clean
Architecture principles, it offers an intuitive interface for managing your workspace spaces and windows directly from
the menu bar.

### ✨ Key Features

- 🎨 **Beautiful UI**: Modern SwiftUI interface with smooth animations and hover effects
- ⚡ **Lightning Fast**: Optimized performance with efficient data refresh and icon caching
- 🏗️ **Clean Architecture**: Built with MVVM Clean Architecture for maintainability
- 🔒 **Privacy Focused**: Runs entirely locally, no data sent to external servers
- 🔧 **Space Groups**: Organize and manage workspace groups with custom ranges and settings
- 🎛️ **Advanced Settings**: Comprehensive customization including themes, performance, and developer options
- 🚀 **Feature Flags**: Dynamic feature management system for controlled feature rollout
- 📊 **Performance Metrics**: Optional performance monitoring and optimization controls
- 🌐 **System Integration**: Automatic menu bar visibility matching and wallpaper detection
- 🎯 **Empty Space Management**: Option to show or hide empty workspace spaces

## 🏗️ Architecture

AeroSpaceBar follows the **MVVM Clean Architecture** pattern, ensuring code maintainability, testability, and
scalability:

### Project Structure

```
AeroSpaceBar/
├── 📁 Sources/                         # Source Code
│   ├── 📁 Domain/                      # Business Logic Layer
│   │   ├── 📁 Entities/                # Core business models, configuration & logging
│   │   ├── 📁 Gateways/                # Repository contracts/protocols
│   │   └── 📁 UseCases/                # Application business logic operations
│   │       ├── 📁 Configuration/       # App settings and preferences
│   │       ├── 📁 FeatureFlags/        # Feature flag management
│   │       ├── 📁 Spaces/             # AeroSpace window manager integration
│   │       └── 📁 SystemMenuBar/      # macOS menu bar interaction
│   ├── 📁 Service/                     # Data Access Layer
│   │   ├── 📁 Network/                 # AeroSpace CLI client & icon cache
│   │   └── 📁 Repositories/            # Gateway implementations
│   │       └── 📁 AeroSpace/          # AeroSpace-specific data access
│   └── 📁 Presentation/                # UI Layer
│       ├── 📁 ViewModels/              # MVVM ViewModels using Combine
│       ├── 📁 Views/                   # SwiftUI Views
│       │   ├── 📁 CommonViews/         # Shared UI components
│       │   ├── 📁 GroupsViews/         # Space group management
│       │   ├── 📁 MenuViews/           # Menu bar interface
│       │   ├── 📁 SettingsViews/       # Settings and configuration
│       │   └── 📁 SpacesViews/         # Space and window management
│       ├── 📁 Resources/               # App resources (localization, assets)
│       ├── 📄 DependencyContainer.swift # Application dependency injection
│       ├── 📄 AppDelegate.swift        # Application entry point
│       └── 📄 AeroSpaceBarApp.swift    # SwiftUI app entry point
├── 📁 Tests/                           # Test Suite
│   ├── 📁 DomainTests/                 # Domain layer tests
│   │   ├── 📁 EntitiesTests/           # Entity and model tests
│   │   ├── 📁 GatewaysTests/           # Gateway contract tests
│   │   └── 📁 UseCasesTests/           # Business logic tests
│   ├── 📁 ServiceTests/                # Service layer tests
│   ├── 📁 PresentationTests/           # Presentation layer unit tests
│   └── 📁 PresentationUITests/         # UI integration tests
│       └── 📁 PresentationUITests/     # End-to-end test scenarios
│           ├── 📁 ViewModelsUITests/   # ViewModel UI tests
│           └── 📁 ViewsUITests/        # View UI tests
├── 📁 AeroSpaceBar.xcodeproj/          # Xcode Project
├── 📁 Common/                          # Kotlin Multiplatform target for IntelliJ IDEA Support
├── 📁 Docs/                            # Documentation
│   └── 📁 Assets/                      # Documentation assets
├── 📁 .vscode/                         # VS Code configuration
├── 📁 gradle/                          # Gradle wrapper files
├── 📁 .idea/                           # IntelliJ IDEA configuration
├── 📄 .swiftformat                     # SwiftFormat configuration
├── 📄 .swiftlint.yml                   # SwiftLint configuration
├── 📄 .gitignore                       # Git ignore rules
├── 📄 .gitattributes                   # Git attributes configuration
├── 📄 build.gradle.kts                 # Gradle build configuration
├── 📄 settings.gradle.kts              # Gradle settings configuration
├── 📄 gradle.properties                # Gradle properties
├── 📄 gradlew                          # Gradle wrapper script (Unix)
├── 📄 gradlew.bat                      # Gradle wrapper script (Windows)
├── 📄 Package.swift                    # Swift Package Manager configuration
├── 📄 Package.resolved                 # Swift Package Manager lock file
├── 📄 CLAUDE.md                        # Claude Code development instructions
└── 📄 README.md                        # Project documentation
```

### 🎯 Architecture Benefits

- **Separation of Concerns**: Clear boundaries between business logic, data access, and UI
- **Testability**: Each layer can be tested independently
- **Maintainability**: Easy to modify and extend functionality
- **Scalability**: Ready for future features and improvements
- **SOLID Compliance**: Follows SOLID principles with 8.6/10 compliance score
- **Dependency Injection**: Centralized dependency management through DependencyContainer
- **Protocol-Oriented Design**: Interface segregation and dependency inversion

## 🚀 Getting Started

### Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **AeroSpace window manager** installed and running
- **Xcode 15.0+** (for development)
- **Swift 6.2+** (latest Swift toolchain)
- **Gradle 8.0+** (for build automation) - included via wrapper

### Installation

> Note on Notarization

By using AeroSpaceBar, you acknowledge that it's not notarized.

Notarization is a "security" feature by Apple. You send binaries to Apple, and they either approve them or not. In
reality, notarization is about building binaries the way Apple likes it.

I don't have anything against notarization as a concept. I specifically don't like the way Apple does notarization. I
don't have time to deal with Apple.

#### Troubleshooting: Launching Non‑Notarized Apps

If macOS blocks the app from launching:

- Right‑click the app in Finder and choose "Open", then click "Open" again in the dialog.
- Or go to System Settings → Privacy & Security → under Security, click "Allow Anyway" for AeroSpaceBar, then try
  opening the app again.
- Optional (advanced): remove the quarantine attribute via Terminal:
  ```bash
  xattr -dr com.apple.quarantine "/Applications/AeroSpaceBar.app"
  ```

#### Option 1: Build from Source (Recommended)

1. **Clone the repository**
   ```bash
   git clone https://github.com/rdrkr/AeroSpaceBar.git
   cd AeroSpaceBar
   ```

2. **Choose your build method:**

   **Option A: Gradle (Recommended)**
   ```bash
   # Build and run in one command
   ./gradlew run
   
   # Or build first, then run
   ./gradlew build
   ./gradlew runDebug
   ```

   **Option B: Xcode (Traditional)**
   ```bash
   open AeroSpaceBar.xcodeproj
   ```

3. **Build and Run**
    - **Gradle**: Use `./gradlew run` to build and launch the app automatically
    - **Xcode**: Select your target device (Mac), press `Cmd + R` or click the Run button
    - The app will appear in your menu bar

#### Option 2: Download Release

1. Go to the [Releases page](https://github.com/rdrkr/AeroSpaceBar/releases)
2. Download the latest `.dmg` file
3. Drag AeroSpaceBar to your Applications folder
4. Launch the app

### Configuration

1. **Ensure AeroSpace is Running**
   ```bash
   # Check if AeroSpace is running
   ps aux | grep aerospace
   
   # Start AeroSpace if not running
   aerospace start
   ```

2. **Customize Settings** (Optional)
    - Click the menu bar icon and select "Settings..." (or press `Cmd + ,`)
    - Configure wallpaper, transparency, and other options
    - Access advanced settings for logging, performance, and behavior controls

## 🎮 Usage

### Basic Operations

- **View Spaces**: Click the menu bar icon to see all available spaces
- **Switch Spaces**: Click on any space to focus it
- **View Windows**: Hover over a space to see its windows
- **Focus Windows**: Click on any window to bring it to focus
- **Manage Groups**: Organize spaces into custom groups with configurable ranges
- **Toggle Features**: Enable/disable empty spaces, window titles, and performance metrics

### Menu Bar Interface

The menu bar displays:

- 🎯 **Current Space**: Shows the currently focused space
- 📊 **Space Count**: Number of total spaces (with empty space toggle)
- ⚡ **Status Indicator**: Shows if AeroSpace is running
- 👥 **Groups Display**: Shows configured space groups (when enabled)
- 🎨 **Dynamic Theming**: Adapts to system wallpaper and menu bar visibility

### App Control Menu

The menubar icon provides:

- ⚙️ **Settings...** (`Cmd + ,`): Open comprehensive settings window
  - **General**: Basic appearance and behavior settings
  - **Groups**: Configure space group organization
  - **Developer**: Advanced logging, performance metrics, and feature flags
- ℹ️ **About AeroSpace Bar**: Show app information and version details
- 🚪 **Quit AeroSpaceBar** (`Cmd + Q`): Exit the application

### Keyboard Shortcuts

- `Cmd + ,`: Open settings window
- `Cmd + Q`: Quit application

### Pro Tip: Enhanced Menu Bar Access with Raycast

For an even more powerful menu bar experience, we recommend installing [Raycast](https://www.raycast.com) - a powerful
productivity launcher for macOS. Raycast's "Search Menu Items" feature allows you to:

- 🔍 **Search Menu Bar Apps**: Quickly find and access any menu bar application
- ⚡ **Keyboard-First Navigation**: Access AeroSpaceBar and other menu bar apps without using your mouse
- 🎯 **Quick Access**: Use `Cmd + Space` to search and access menu bar options instantly
- 🔧 **Custom Workflows**: Create shortcuts and workflows for your menu bar apps

**How to use with AeroSpaceBar:**

1. Install [Raycast](https://www.raycast.com) (free for personal use)
2. Use `Cmd + Space` to open Raycast
3. Type "Search Menu Items" or use the built-in menu bar search
4. Search for "AeroSpaceBar" to quickly access the app's menu options

This combination provides a seamless, keyboard-driven workflow for managing your AeroSpace spaces and windows!

## 🛠️ Development

### Project Structure

The project is organized following Clean Architecture principles with comprehensive testing:

#### Source Code (`Sources/`)

- **Domain Layer**: Core business logic, entities, use cases, and gateway contracts with no external dependencies
- **Service Layer**: Repository implementations, data models, network clients, and AeroSpace CLI integration
- **Presentation Layer**: MVVM ViewModels using Combine, SwiftUI Views, and app resources

#### Test Suite (`Tests/`)

- **DomainTests**: Entity, gateway, and use case tests for business logic validation
- **ServiceTests**: Repository, network client, and data layer integration tests
- **PresentationTests**: ViewModel and presentation layer unit tests
- **PresentationUITests**: End-to-end user interface and interaction tests

#### Development Tools

- **VS Code**: Development environment configuration
- **Gradle**: Build system and task automation
- **Swift Package Manager**: Dependency management for Swift packages

### Code Style

- **SwiftLint**: Follows SwiftLint rules for consistent code style
- **SwiftFormat**: Automated code formatting with `.swiftformat` configuration
- **Documentation**: All public APIs are documented using Swift documentation markup
- **Naming**: Follows Swift naming conventions
- **Architecture**: Strict adherence to Clean Architecture principles
- **SOLID Principles**: Strict adherence to SOLID principles

### Build System

AeroSpaceBar supports **dual build systems** for maximum flexibility:

#### Gradle Commands (Recommended)

Use the provided Gradle build system for all development tasks:

```bash
# Show all available tasks
./gradlew showHelp

# Build commands
./gradlew build        # Build all variants (Debug and Release)
./gradlew buildDebug   # Build Debug configuration only
./gradlew buildRelease # Build Release configuration only
./gradlew run          # Build and run the application
./gradlew clean        # Clean build artifacts

# Code quality
./gradlew check        # Run format + lint checks
./gradlew lintFix      # Auto-fix linting issues
./gradlew format       # Format code with SwiftFormat
./gradlew lint         # Lint code with SwiftLint

# Testing
./gradlew test         # Run all tests

# All-in-one
./gradlew all          # Run clean + check + build
```

#### Xcode Commands (Alternative)

Traditional Xcode build commands are also supported:

```bash
# Build project
xcodebuild -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar build

# Run tests
xcodebuild -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar test

# Build specific configuration
xcodebuild -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -configuration Debug build
```

### Dependencies

The project uses modern Swift Package Manager dependencies:

- **[TOMLKit](https://github.com/LebJe/TOMLKit)**: TOML configuration file parsing for AeroSpace configuration files
- **AppIntents.framework**: Native macOS framework for app integration and metadata extraction
- **Standard macOS Frameworks**: SwiftUI, Combine, AppKit for native system integration

### Linting & Formatting

- SwiftFormat configuration: `.swiftformat` (120 char line limit, 4-space indentation)
- SwiftLint configuration: `.swiftlint.yml` (extensive opt-in rules, analyzer rules)
- Run locally:
    - `./gradlew format` to format the codebase
    - `./gradlew lint` to report style issues
    - `./gradlew lintFix` to auto-fix fixable issues
    - `./gradlew check` to run both format and lint
- **Note**: SwiftFormat and SwiftLint configurations are aligned to prevent conflicts

## 🧪 Testing

### Running Tests

#### Using Gradle (Recommended)

```bash
# Run all tests
./gradlew test

# Run specific test targets
./gradlew test -PtestTarget=DomainTests
./gradlew test -PtestTarget=ServiceTests
./gradlew test -PtestTarget=PresentationTests
./gradlew test -PtestTarget=PresentationUITests
```

#### Using Xcode

```bash
# Run all tests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar

# Run specific test targets
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:DomainTests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:ServiceTests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:PresentationTests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:PresentationUITests
```

### Test Structure

- **Unit Tests**: Test individual components and use cases
- **Integration Tests**: Test data layer and external dependencies
- **UI Tests**: Test user interface interactions

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Development Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
2. **Make your changes**
3. **Add tests** for new functionality
4. **Ensure all tests pass**
   ```bash
   ./gradlew all
   ```
5. **Submit a pull request**

### Code Standards

- Follow SwiftLint rules
- Add documentation
- Write unit tests for new functionality
- Follow Clean Architecture principles
- Use meaningful commit messages

### Pull Request Guidelines

- Provide a clear description of changes
- Include screenshots for UI changes
- Ensure all CI checks pass
- Update documentation if needed

## 📝 License

This project is licensed under the **GNU Affero General Public License v3.0** - see the [LICENSE](LICENSE) file for
details.

The AGPL-3.0 license ensures that:

- All derivative works must remain open source
- Network use triggers source code distribution requirements
- Patent protection is included
- No proprietary restrictions can be added

## 🙏 Acknowledgments

- **[AeroSpace](https://github.com/nikitabobko/aerospace)**: The amazing window manager that makes this possible
- **[barik](https://github.com/mocki-toki/barik)**: A lightweight macOS menu bar replacement with yabai and AeroSpace
  support
- **[Clean Architecture MVVM](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)**: Architecture inspiration and
  guidelines
- **[SwiftUI](https://developer.apple.com/xcode/swiftui/)**: Modern UI framework from Apple
- **[Combine](https://developer.apple.com/documentation/combine)**: Reactive programming framework
- **[TOMLKit](https://github.com/LebJe/TOMLKit)**: TOML parsing library for AeroSpace configuration files

## 📞 Support

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/rdrkr/AeroSpaceBar/issues)
- **Discussions**: [GitHub Discussions](https://github.com/rdrkr/AeroSpaceBar/discussions)

---

<div align="center">

**Made with ❤️ by [Ronen Druker](https://github.com/rdrkr)**

[⭐ Star this repo](https://github.com/rdrkr/AeroSpaceBar/stargazers) | [🐛 Report a bug](https://github.com/rdrkr/AeroSpaceBar/issues) | [💡 Request a feature](https://github.com/rdrkr/AeroSpaceBar/issues/new)

</div>
