# 🚀 AeroSpaceBar

<div align="center">
  <img src="Docs/Assets/AeroSpaceBar-macOS-Default-512x512@1x.png" alt="AeroSpaceBar App Icon" width="128" height="128">
</div>

> **A modern macOS menu bar application for managing AeroSpace window manager spaces and windows with a beautiful SwiftUI interface**

[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL%203.0-blue.svg)](https://opensource.org/licenses/AGPL-3.0)
[![Swift](https://img.shields.io/badge/Swift-6.2+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-14.0+-silver.svg)](https://www.apple.com/macos/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20Clean%20Architecture-green.svg)](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)

<div align="center">
  <img src="Docs/Assets/demo.gif" alt="Demo">
</div>

## 📖 Overview

AeroSpaceBar is a sophisticated macOS menu bar application that provides seamless integration with the [AeroSpace window manager](https://github.com/nikitabobko/aerospace). Built with modern SwiftUI and following Clean Architecture principles, it offers an intuitive interface for managing your workspace spaces and windows directly from the menu bar.

### ✨ Key Features

- 🎨 **Beautiful UI**: Modern SwiftUI interface with smooth animations and hover effects
- ⚡ **Lightning Fast**: Optimized performance with efficient data refresh
- 🏗️ **Clean Architecture**: Built with MVVM Clean Architecture for maintainability
- 🔒 **Privacy Focused**: Runs entirely locally, no data sent to external servers

## 🏗️ Architecture

AeroSpaceBar follows the **MVVM Clean Architecture** pattern, ensuring code maintainability, testability, and scalability:

### Project Structure

```
AeroSpaceBar/
├── 📁 AeroSpaceBar/                    # Main Application
│   ├── 📁 Data/                        # Data Layer
│   │   ├── 📁 Models/                  # External data models
│   │   ├── 📁 Network/                 # AeroSpace CLI client
│   │   └── 📁 Repositories/            # Repository implementations
│   ├── 📁 Domain/                      # Business Layer
│   │   ├── 📁 Entities/                # Business models, configuration & logging
│   │   ├── 📁 Gateways/                # Repository contracts
│   │   └── 📁 UseCases/                # Application business logic
│   ├── 📁 Presentation/                # Presentation Layer
│   │   ├── 📁 ViewModels/              # MVVM ViewModels
│   │   └── 📁 Views/                   # SwiftUI Views
│   │       ├── 📁 SettingsViews/       # Settings-related views
│   │       └── 📁 Common/              # Shared UI components
│   ├── 📁 Resources/                   # App resources (localization, assets)
│   ├── 📄 DependencyContainer.swift    # Application DI
│   ├── 📄 AppDelegate.swift            # Application Entry Point
│   └── 📄 AeroSpaceBarApp.swift        # SwiftUI App Entry Point
├── 📁 AeroSpaceBarTests/               # Unit Tests
│   ├── 📁 DataTests/                   # Data layer tests
│   │   ├── 📁 ModelsTests/             # Model tests
│   │   ├── 📁 NetworkTests/            # Network client tests
│   │   └── 📁 RepositoriesTests/       # Repository tests
│   └── 📁 DomainTests/                 # Domain layer tests
│       ├── 📁 EntitiesTests/           # Entity tests
│       ├── 📁 GatewaysTests/           # Gateway tests
│       └── 📁 UseCasesTests/           # Use case tests
├── 📁 AeroSpaceBarUITests/             # UI Tests
│   ├── 📁 FlowsUITests/                # End-to-end test scenarios
│   └── 📁 PresentationUITests/         # Presentation layer UI tests
│       ├── 📁 ViewModelsTests/         # ViewModel tests
│       └── 📁 ViewsTests/              # View tests
│           ├── 📁 SettingsViewsTests/  # Settings view tests
│           └── 📁 CommonTests/         # Common component tests
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

### Installation

> Note on Notarization

By using AeroSpaceBar, you acknowledge that it's not notarized.

Notarization is a "security" feature by Apple. You send binaries to Apple, and they either approve them or not. In reality, notarization is about building binaries the way Apple likes it.

I don't have anything against notarization as a concept. I specifically don't like the way Apple does notarization. I don't have time to deal with Apple.

#### Troubleshooting: Launching Non‑Notarized Apps

If macOS blocks the app from launching:

- Right‑click the app in Finder and choose "Open", then click "Open" again in the dialog.
- Or go to System Settings → Privacy & Security → under Security, click "Allow Anyway" for AeroSpaceBar, then try opening the app again.
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

   **Option A: Xcode (Traditional)**
   ```bash
   open AeroSpaceBar.xcodeproj
   ```
   
   **Option B: Gradle (Modern)**
   ```bash
   ./gradlew build
   ```

3. **Build and Run**
   - **Xcode**: Select your target device (Mac), press `Cmd + R` or click the Run button
   - **Gradle**: Use `./gradlew run` to build and launch the app
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

### Menu Bar Interface

The menu bar displays:
- 🎯 **Current Space**: Shows the currently focused space
- 📊 **Space Count**: Number of total spaces
- ⚡ **Status Indicator**: Shows if AeroSpace is running

### App Control Menu

The menubar icon provides:
- ⚙️ **Settings...** (`Cmd + ,`): Open settings window
- ℹ️ **About AeroSpace Bar**: Show app information
- 🚪 **Quit AeroSpaceBar** (`Cmd + Q`): Exit the application

### Keyboard Shortcuts

- `Cmd + ,`: Open settings window
- `Cmd + Q`: Quit application

### Pro Tip: Enhanced Menu Bar Access with Raycast

For an even more powerful menu bar experience, we recommend installing [Raycast](https://www.raycast.com) - a powerful productivity launcher for macOS. Raycast's "Search Menu Items" feature allows you to:

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

#### Main Application (`AeroSpaceBar/`)
- **Domain Layer**: Core business logic, entities, use cases, and gateway contracts
- **Data Layer**: Repository implementations, data models, and network clients
- **Presentation Layer**: MVVM ViewModels and SwiftUI Views
- **Resources**: Localization files, assets, and app configuration

#### Unit Tests (`AeroSpaceBarTests/`)
- **DataTests**: Repository, model, and network client tests
- **DomainTests**: Entity, gateway, and use case tests  

#### UI Tests (`AeroSpaceBarUITests/`)
- **FlowsUITests**: End-to-end user journey scenarios
- **PresentationUITests**: User interface interaction tests

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

#### Gradle Commands

Use the provided Gradle build system for common developer tasks:

```bash
# Show available tasks
./gradlew showHelp
```

#### Xcode Commands

Traditional Xcode build commands still work:

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

- **[TOMLKit](https://github.com/LebJe/TOMLKit)**: TOML configuration file parsing
- **[R.swift](https://github.com/mac-cain13/R.swift)**: Type-safe resource management for images, fonts, and other assets

### Linting & Formatting

- SwiftFormat configuration: `.swiftformat`
- SwiftLint configuration: `.swiftlint.yml`
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

# Run specific test target
./gradlew test -PtestTarget=AeroSpaceBarTests
```

#### Using Xcode
```bash
# Run all tests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar

# Run specific test target
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:AeroSpaceBarTests
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
   ./gradlew check test
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

This project is licensed under the **GNU Affero General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

The AGPL-3.0 license ensures that:
- All derivative works must remain open source
- Network use triggers source code distribution requirements
- Patent protection is included
- No proprietary restrictions can be added

## 🙏 Acknowledgments

- **[AeroSpace](https://github.com/nikitabobko/aerospace)**: The amazing window manager that makes this possible
- **[barik](https://github.com/mocki-toki/barik)**: A lightweight macOS menu bar replacement with yabai and AeroSpace support
- **[Clean Architecture MVVM](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)**: Architecture inspiration and guidelines
- **[SwiftUI](https://developer.apple.com/xcode/swiftui/)**: Modern UI framework from Apple
- **[Combine](https://developer.apple.com/documentation/combine)**: Reactive programming framework
- **[TOMLKit](https://github.com/LebJe/TOMLKit)**: TOML parsing library
- **[R.swift](https://github.com/mac-cain13/R.swift)**: Type-safe resource management

## 📞 Support

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/rdrkr/AeroSpaceBar/issues)
- **Discussions**: [GitHub Discussions](https://github.com/rdrkr/AeroSpaceBar/discussions)

---

<div align="center">

**Made with ❤️ by [Ronen Druker](https://github.com/rdrkr)**

[⭐ Star this repo](https://github.com/rdrkr/AeroSpaceBar/stargazers) | [🐛 Report a bug](https://github.com/rdrkr/AeroSpaceBar/issues) | [💡 Request a feature](https://github.com/rdrkr/AeroSpaceBar/issues/new)

</div>
