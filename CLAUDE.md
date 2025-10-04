# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

### Build System

This project uses **Swift Package Manager (SPM)** for library targets (Domain, Data, Presentation) and standard **Xcode
** for the main application target.

```bash
# Build commands using xcodebuild
xcodebuild -scheme AeroSpaceBar -configuration Debug build
xcodebuild -scheme AeroSpaceBar -configuration Release build

# Clean build artifacts
xcodebuild -scheme AeroSpaceBar clean

# Or use the automation scripts
./Scripts/build.sh                     # Build Release configuration
./Scripts/build.sh -c Debug            # Build Debug configuration
./Scripts/build.sh --clean             # Clean and build

# Code quality (SwiftFormat and SwiftLint must be installed)
swiftformat .
swiftlint --fix
```

## Code Quality Tools

- **SwiftFormat**: Code formatting with `.swiftformat` config (120 char line limit, 4-space indentation)
- **SwiftLint**: Strict linting with `.swiftlint.yaml` config (extensive opt-in rules, analyzer rules)
- Both tools are aligned to prevent conflicts and should always be run before committing

## Architecture Overview

AeroSpaceBar follows **MVVM Clean Architecture** principles with strict layer separation:

### Project Structure

```
├── Packages/                          # Swift Package Manager packages
│   ├── Domain/                        # Business Logic Layer (SPM package)
│   │   ├── Sources/Domain/
│   │   │   ├── Entities/             # Core business models, configuration, logging
│   │   │   ├── Gateways/             # Repository contracts/protocols
│   │   │   └── UseCases/             # Application business logic operations
│   │   └── Tests/DomainTests/
│   ├── Data/                          # Data Access Layer (SPM package)
│   │   ├── Sources/Data/
│   │   │   ├── Models/               # External data models (from AeroSpace CLI)
│   │   │   ├── Network/              # AeroSpaceCLIClient, IconCache
│   │   │   └── Repositories/         # Gateway implementations
│   │   └── Tests/DataTests/
│   └── Presentation/                  # UI Layer (SPM package)
│       ├── Sources/Presentation/
│       │   ├── ViewModels/           # MVVM ViewModels using Combine
│       │   └── Views/                # SwiftUI Views + Common components
│       └── Tests/PresentationTests/
├── AeroSpaceBar/                      # Main application target
│   ├── AeroSpaceBarApp.swift         # App entry point
│   ├── Info.plist                    # App customizations (version in Xcode project)
│   ├── AeroSpaceBar.entitlements     # App entitlements
│   └── Resources/                    # App resources
├── AeroSpaceBar.xcodeproj/            # Xcode project
└── Scripts/                           # Automation scripts for release management
```

### Key Architectural Patterns

1. **Clean Architecture**: Strict separation of concerns, dependencies point inward
2. **MVVM with Combine**: ViewModels use Combine for reactive data binding
3. **Functional Programming**: Favor immutability, pure functions, and higher-order functions
4. **Dependency Injection**: All dependencies managed through `DependencyContainer.swift`
5. **Use Case Pattern**: Each business operation isolated in its own use case class. Repositories' and gateways'
   functionality are only accessible via Use Cases
6. **Protocol-Oriented Design**: All gateways defined as protocols in Domain layer
7. **Repository Pattern**: Data access abstracted through gateway protocols
8. **Single Responsibility Principle**: Each class has one reason to change
9. **Separation of Concerns**: Clear boundaries between layers, no direct dependencies from
10. **Modern Swift**: Use the most modern (6.2+) language features and conventions. Target Swift 6 and use Swift
    concurrency (async/await, actors) and Swift macros where applicable.

### Core Components

- **DependencyContainer**: Centralized DI container managing all service lifetimes
- **SpacesGateway**: Main interface for AeroSpace window manager interaction
- **ConfigurationGateway**: User settings and preferences management
- **IconCache**: Performance-optimized application icon caching
- **AeroSpaceCLIClient**: Direct interface to AeroSpace CLI commands

## Development Patterns

### Adding New Features

1. Create domain entities and use cases first (no dependencies)
2. Add gateway protocols to Domain/Gateways/
3. Implement repositories in Data layer
4. Create ViewModels in Presentation/ViewModels/
5. Add Views in Presentation/Views/
6. Wire dependencies in DependencyContainer
7. Write tests for each layer

### Testing Strategy

- For every change you make, verify your changes by building: `./Scripts/build.sh -c Debug`
- **Unit Tests**:
    - `Packages/Domain/Tests/DomainTests/` - Domain layer testing
    - `Packages/Data/Tests/DataTests/` - Data layer testing
    - `Packages/Presentation/Tests/PresentationTests/` - Presentation layer testing
- **UI Tests**: `Packages/Presentation/Tests/PresentationUITests/` - End-to-end user flow testing
- Test files mirror source structure for easy navigation
- Run tests: `xcodebuild test -scheme AeroSpaceBar`

### Configuration Management

- App settings stored via `ConfigurationGateway` (UserDefaults-based)
- AeroSpace integration via `AeroSpaceCLIClient`
- Default values defined in `ConfigurationDefaults.swift`
- User setting keys centralized in `UserDefaultsKeys.swift`

## Dependencies

### SPM Package Dependencies

- **Domain Package**:
    - `ModifiedCopyMacro` - Swift macro for copy-on-write semantics
- **Data Package**:
    - `TOMLKit` - TOML configuration file parsing for AeroSpace configs
    - `AsyncFileMonitor` - Async file system monitoring
    - `Sparkle` - Software update framework
- **Presentation Package**:
    - Depends on Data package (which transitively includes Domain)

### Platform Requirements

- **macOS**: 14.0+ (Domain/Data), 15.0+ (Presentation)
- **Swift**: 6.2+
- **Xcode**: 16.0+
- **Build System**: Swift Package Manager + Xcode

## Version Management

- **Version Information**: Controlled exclusively by Xcode project settings
    - `MARKETING_VERSION` - App version (e.g., "1.0.0")
    - `CURRENT_PROJECT_VERSION` - Build number (e.g., "1")
- **Info.plist**: Contains only app customizations, NOT version information
- **Version Scripts**:
    - `./Scripts/version.sh` - Read current version from Xcode project
    - `./Scripts/bump-version.sh <version>` - Update version in Xcode project only
- **Important**: Never manually edit version in Info.plist - use scripts or Xcode project settings

## Special Considerations

- **Thread Safety**: DependencyContainer runs on @MainActor
- **Performance**: IconCache and optimized refresh settings for menu bar responsiveness
- **AeroSpace Integration**: Communicates via CLI commands, requires AeroSpace installation
- **Menu Bar App**: Uses NSStatusBar for system menu bar integration
- **Clean Architecture Compliance**: Strict dependency rules - Domain has no external dependencies
- **Swift Concurrency**: Use async/await and actors for concurrency where applicable
- **Swift Generics**: Leverage Swift generics for reusable components
- **SPM Package Isolation**: Each package (Domain, Data, Presentation) is independently buildable and testable

## Documentation Standards

- All public methods, properties, and classes must have SwiftDoc comments
- Follow Swift API Design Guidelines for naming and structure
- Use meaningful names and avoid abbreviations
- Document complex logic and decisions in code comments
- Keep documentation up to date with code changes, including README.md and inline comments

## Common Tasks

When adding new settings:

1. Add key to `UserDefaultsKeys.swift`
2. Add default to `ConfigurationDefaults.swift`
3. Create get/set use cases in `Domain/UseCases/Configuration/`
4. Add methods to `ConfigurationGateway` protocol and implementation
5. Wire in `DependencyContainer.swift`
6. Update ViewModels and Views accordingly

When adding AeroSpace features:

1. Add methods to `SpacesGateway` protocol
2. Implement in `AeroSpaceRepository.swift`
3. Create use cases in `Domain/UseCases/`
4. Update ViewModels to use new use cases

- Avoid code duplication and repeatition of values.
- Prefer let const properties for strings and other constants

## UI Development Rules

### Localization

- **Never use raw strings for end-user presented text**: All user-facing text must use `LocalizedStringResource` for
  proper internationalization support. This includes button titles, labels, descriptions, error messages, and any text
  that users will see.
- Examples:
    - ✅ `LocalizedStringResource("Save Changes")`
    - ❌ `"Save Changes"`
    - ✅ `LocalizedStringResource("Choose the background color for \(entityType) elements.")`
    - ❌ `"Choose the background color for \(entityType) elements."`

### View Architecture

- **Subviews must not access ViewModels directly**: Views which are owned by root views should not have direct access to
  ViewModels. The root view should pass only the relevant properties and functions to the subviews it uses. This ensures
  proper separation of concerns and makes components more reusable.
- Examples:
    - ✅ Root view passes specific bindings and callbacks to subviews
    - ❌ Subview directly accesses `@EnvironmentObject private var viewModel: SomeViewModel`
    - ✅ `SubView(value: $viewModel.specificProperty, onAction: viewModel.handleAction)`
    - ❌ `SubView()` where `SubView` internally accesses the ViewModel

### Concurrency

- **Use modern Swift concurrency over DispatchQueue**: Replace all DispatchQueue usage with Swift 6 async/await patterns
  for better type safety and performance.
- Examples:
    - ✅ `Task { @MainActor in /* UI updates */ }`
    - ❌ `DispatchQueue.main.async { /* UI updates */ }`
    - ✅ `try await Task.sleep(for: .seconds(1))`
    - ❌ `DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { }`
    - ✅ `Task.detached(priority: .userInitiated) { /* background work */ }`
    - ❌ `DispatchQueue(label: "background", qos: .userInitiated).async { }`
- Always update @README.md with relevant changes, such as, referenced files/directories, folder sturcture, dependendencies added/changed/removed, scripts, etc.