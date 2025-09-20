# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

### Gradle Build System

This project uses Gradle as the primary build system with comprehensive task automation:

```bash
# Show all available tasks with descriptions
./gradlew showHelp

# Build commands
./gradlew build        # Build all variants (Debug and Release)
./gradlew buildDebug   # Build Debug configuration only
./gradlew buildRelease # Build Release configuration only
./gradlew clean        # Clean build artifacts and DerivedData

# Code quality
./gradlew lintFix      # Auto-fix linting issues where possible
./gradlew check        # Run format + lint together

# All-in-one
./gradlew all          # Run clean + check + build
```

## Code Quality Tools

- **SwiftFormat**: Code formatting with `.swiftformat` config (120 char line limit, 4-space indentation)
- **SwiftLint**: Strict linting with `.swiftlint.yml` config (extensive opt-in rules, analyzer rules)
- Both tools are aligned to prevent conflicts and should always be run before committing

## Architecture Overview

AeroSpaceBar follows **MVVM Clean Architecture** principles with strict layer separation:

### Layer Structure

```
├── Domain/           # Business Logic Layer (no dependencies)
│   ├── Entities/     # Core business models, configuration, logging
│   ├── Gateways/     # Repository contracts/protocols
│   └── UseCases/     # Application business logic operations
├── Service/          # Data Access Layer
│   ├── Models/       # External data models (from AeroSpace CLI)
│   ├── Network/      # AeroSpaceCLIClient, IconCache
│   └── Repositories/ # Gateway implementations
└── Presentation/     # UI Layer
    ├── ViewModels/   # MVVM ViewModels using Combine
    └── Views/        # SwiftUI Views + Common components
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
3. Implement repositories in Service/ (Data) layer
4. Create ViewModels in Presentation/ViewModels/
5. Add Views in Presentation/Views/
6. Wire dependencies in DependencyContainer
7. Write tests for each layer

### Testing Strategy

- For every change you make, verify your changes by running "./gradlew buildDebug"
- **Unit Tests** (`AeroSpaceBarTests/`): Domain and Service layer testing
- **UI Tests** (`AeroSpaceBarUITests/`): End-to-end user flow testing
- Test files mirror source structure for easy navigation

### Configuration Management

- App settings stored via `ConfigurationGateway` (UserDefaults-based)
- AeroSpace integration via `AeroSpaceCLIClient`
- Default values defined in `ConfigurationDefaults.swift`
- User setting keys centralized in `UserDefaultsKeys.swift`

## Dependencies

- **TOMLKit**: TOML configuration file parsing for AeroSpace configs
- **R.swift**: Type-safe resource management for images and assets
- **Platform**: macOS 14.0+, Swift 6.2+, Xcode 15.0+

## Special Considerations

- **Thread Safety**: DependencyContainer runs on @MainActor
- **Performance**: IconCache and optimized refresh settings for menu bar responsiveness
- **AeroSpace Integration**: Communicates via CLI commands, requires AeroSpace installation
- **Menu Bar App**: Uses NSStatusBar for system menu bar integration
- **Clean Architecture Compliance**: Strict dependency rules - Domain has no external dependencies
- **Swift Concurrency**: Use async/await and actors for concurrency where applicable
- **Swift Generics**: Leverage Swift generics for reusable components

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
- **Never use raw strings for end-user presented text**: All user-facing text must use `LocalizedStringResource` for proper internationalization support. This includes button titles, labels, descriptions, error messages, and any text that users will see.
- Examples:
  - ✅ `LocalizedStringResource("Save Changes")`
  - ❌ `"Save Changes"`
  - ✅ `LocalizedStringResource("Choose the background color for \(entityType) elements.")`
  - ❌ `"Choose the background color for \(entityType) elements."`

### View Architecture
- **Subviews must not access ViewModels directly**: Views which are owned by root views should not have direct access to ViewModels. The root view should pass only the relevant properties and functions to the subviews it uses. This ensures proper separation of concerns and makes components more reusable.
- Examples:
  - ✅ Root view passes specific bindings and callbacks to subviews
  - ❌ Subview directly accesses `@EnvironmentObject private var viewModel: SomeViewModel`
  - ✅ `SubView(value: $viewModel.specificProperty, onAction: viewModel.handleAction)`
  - ❌ `SubView()` where `SubView` internally accesses the ViewModel

### Concurrency
- **Use modern Swift concurrency over DispatchQueue**: Replace all DispatchQueue usage with Swift 6 async/await patterns for better type safety and performance.
- Examples:
  - ✅ `Task { @MainActor in /* UI updates */ }`
  - ❌ `DispatchQueue.main.async { /* UI updates */ }`
  - ✅ `try await Task.sleep(for: .seconds(1))`
  - ❌ `DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { }`
  - ✅ `Task.detached(priority: .userInitiated) { /* background work */ }`
  - ❌ `DispatchQueue(label: "background", qos: .userInitiated).async { }`