# 🚀 AeroSpaceBar

<!--suppress HtmlDeprecatedAttribute -->
<div align="center">
  <!--suppress CheckImageSize -->
<img src="Docs/Assets/AeroSpaceBar-macOS-Default-512x512@1x.png" alt="AeroSpaceBar App Icon" width="128" height="128">
</div>

> **A modern macOS menu bar application for managing AeroSpace window manager spaces and windows with a beautiful
SwiftUI interface**

[![License: Proprietary](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/Swift-6.2+-blue.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-15.0+-gold.svg)](https://www.apple.com/macos/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20Clean%20Architecture-green.svg)](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)
[![Release](https://github.com/rdrkr/AeroSpaceBar/actions/workflows/release.yaml/badge.svg)](https://github.com/rdrkr/AeroSpaceBar/actions/workflows/release.yaml)

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
- 🔧 **Spaces & Groups**: Organize and manage workspace windows and menubar groups with custom ranges and settings
- 🎨 **Advanced Theming**: Comprehensive theme system with presets, per-space customization, and visual properties
- 🎛️ **Advanced Settings**: Comprehensive customization including themes, performance, and developer options
- 🚀 **Feature Flags**: Dynamic feature management system for controlled feature rollout
- 🌐 **System Integration**: Automatic menu bar visibility matching and wallpaper detection
- 🔄 **Software Updates**: Automatic update checking and installation via Sparkle framework
- ⚙️ **TOML Configuration**: Native support for AeroSpace TOML configuration file monitoring
- ⌨️ **Keyboard Shortcuts**: Advanced keyboard shortcut support and global key detection
- 🖥️ **Screen Capture Support**: Optional screen sharing permission handling for advanced features
- 🎨 **Per-Space Customization**: Individual visual properties for each workspace

## 🏗️ Architecture

AeroSpaceBar follows the **MVVM Clean Architecture** pattern, ensuring code maintainability, testability, and
scalability:

### Project Structure

```
AeroSpaceBar/
├── 📁 AeroSpaceBar/                      # Main application target
│   ├── 📄 AeroSpaceBarApp.swift          # SwiftUI app entry point
│   ├── 📄 Info.plist                     # App customizations (version in Xcode project)
│   ├── 📄 AeroSpaceBar.entitlements      # App entitlements
│   └── 📁 Resources/                     # App-specific resources
├── 📁 Packages/                          # Swift Package Manager packages
│   ├── 📁 Data/                          # Data Access Layer (SPM package)
│   │   ├── 📁 Sources/Data/
│   │   │   ├── 📁 Network/               # AeroSpace CLI client & icon cache
│   │   │   ├── 📁 Models/                # External data models
│   │   │   └── 📁 Repositories/          # Gateway implementations
│   │   ├── 📁 Tests/DataTests/           # Data layer tests
│   │   └── 📄 Package.swift              # SPM package manifest
│   ├── 📁 Domain/                        # Business Logic Layer (SPM package)
│   │   ├── 📁 Sources/Domain/
│   │   │   ├── 📁 Entities/              # Core business models, configuration & logging
│   │   │   │   ├── 📁 Common/            # Shared entities (Logger, AppError, etc.)
│   │   │   │   ├── 📁 Configuration/     # Configuration models and defaults
│   │   │   │   ├── 📁 Group/             # Group-related entities
│   │   │   │   ├── 📁 License/           # Licensing entities
│   │   │   │   ├── 📁 Navigation/        # Navigation entities
│   │   │   │   ├── 📁 Space/             # Space and window entities
│   │   │   │   └── 📁 VisualContainer/   # Theme and visual properties
│   │   │   ├── 📁 Gateways/              # Repository contracts/protocols
│   │   │   └── 📁 UseCases/              # Application business logic operations
│   │   │       ├── 📁 Configuration/     # App settings and preferences
│   │   │       ├── 📁 FeatureFlags/      # Feature flag management
│   │   │       ├── 📁 KeyboardShortcuts/ # Keyboard shortcut handling
│   │   │       ├── 📁 License/           # License management
│   │   │       ├── 📁 SoftwareUpdate/    # Software update functionality
│   │   │       ├── 📁 Spaces/            # AeroSpace window manager integration
│   │   │       └── 📁 SystemMenuBar/     # macOS menu bar interaction
│   │   ├── 📁 Tests/DomainTests/         # Domain layer tests
│   │   └── 📄 Package.swift              # SPM package manifest
│   └── 📁 Presentation/                  # UI Layer (SPM package)
│       ├── 📁 Sources/Presentation/
│       │   ├── 📁 ViewModels/            # MVVM ViewModels using Combine
│       │   ├── 📁 Views/                 # SwiftUI Views
│       │   │   ├── 📁 CommonViews/       # Shared UI components
│       │   │   ├── 📁 GroupsViews/       # Space group management
│       │   │   ├── 📁 MenuViews/         # Menu bar interface
│       │   │   ├── 📁 SettingsViews/     # Settings and configuration
│       │   │   └── 📁 SpacesViews/       # Space and window management
│       ├── 📁 Tests/PresentationTests/   # Presentation layer tests
│       ├── 📁 Tests/PresentationUITests/ # UI integration tests
│       └── 📄 Package.swift              # SPM package manifest
├── 📁 AeroSpaceBar.xcodeproj/            # Xcode Project
├── 📁 Scripts/                           # Automation scripts for release management
│   ├── 📄 version.sh                     # Get version from Xcode project
│   ├── 📄 bump-version.sh                # Update version in Xcode project
│   ├── 📄 build.sh                       # Build using xcodebuild
│   ├── 📄 preflight-check.sh             # Pre-release validation
│   ├── 📄 release.sh                     # Automated release workflow
│   └── ...                               # Additional release automation scripts
├── 📁 Docs/                              # Documentation
│   └── 📁 Assets/                        # Documentation assets
├── 📁 .vscode/                           # VS Code configuration
├── 📁 .idea/                             # IntelliJ IDEA configuration
├── 📄 .swiftformat                       # SwiftFormat configuration
├── 📄 .swiftlint.yaml                    # SwiftLint configuration
├── 📄 .gitignore                         # Git ignore rules
├── 📄 .gitattributes                     # Git attributes configuration
├── 📄 CHANGELOG.md                       # Release notes and version history
├── 📄 CLAUDE.md                          # Claude Code development instructions
└── 📄 README.md                          # Project documentation
```

### 🎯 Architecture Benefits

- **Separation of Concerns**: Clear boundaries between business logic, data access, and UI
- **Testability**: Each layer can be tested independently
- **Maintainability**: Easy to modify and extend functionality
- **Scalability**: Ready for future features and improvements
- **SOLID Compliance**: Follows SOLID principles with 8.6/10 compliance score
- **Dependency Injection**: Centralized dependency management through DependencyContainer
- **Protocol-Oriented Design**: Interface segregation and dependency inversion

## 📦 Repository Structure

This project uses a multi-repository architecture to separate development from public distribution:

### Development Repository (Private)

**Current Repository**: [AeroSpaceBar](https://github.com/rdrkr/AeroSpaceBar)

- Private development repository
- Contains full source code, tests, and development tooling
- Uses proprietary license
- Active development and feature implementation

### Public Repositories

#### 1. [aerospacebar-app](https://github.com/rdrkr/aerospacebar-app)

**Purpose**: Public releases, documentation, and community engagement

- Binary releases (`.zip` files)
- User-facing documentation
- Issue tracking and bug reports
- Feature requests and discussions
- Installation instructions
- Community support

**Usage**: End users download releases from here or install via Homebrew

#### 2. [homebrew-tap](https://github.com/rdrkr/homebrew-tap)

**Purpose**: Official Homebrew tap for easy installation

- Homebrew cask formula for AeroSpaceBar
- Tap-specific documentation
- Formula maintenance and updates

**Usage**: Users install via:

```bash
brew tap rdrkr/tap
brew install --cask aerospacebar
```

### Release Workflow

1. **Development**: All development happens in this private repository
2. **Build**: Create release builds using `./Scripts/build.sh`
3. **Package**: Create `.zip` archive of `AeroSpaceBar.app`
4. **Release**: Upload to [aerospacebar-app releases](https://github.com/rdrkr/aerospacebar-app/releases)
5. **Update Homebrew**: Update formula in [homebrew-tap](https://github.com/rdrkr/homebrew-tap) with new version and
   SHA256

## 🚀 Getting Started

### Prerequisites

#### For Users

- **macOS 15.0+** (Sequoia or later)
- **AeroSpace window manager** installed and running

#### For Developers

- **macOS 15.0+** (Sequoia or later)
- **AeroSpace window manager** installed and running
- **Xcode 16.3+** (for development)
- **Swift 6.2+** (latest Swift toolchain)
- **Development Tools** (for code quality):
  ```bash
  brew install swiftformat swiftlint
  ```
    - **SwiftFormat**: Code formatting (required for builds)
    - **SwiftLint**: Code linting (required for builds)
    - **Note**: The Xcode project includes pre-build scripts that run these tools automatically

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

   **Option A: Build Scripts (Recommended)**
   ```bash
   # Build Release configuration
   ./Scripts/build.sh

   # Build Debug configuration
   ./Scripts/build.sh -c Debug

   # Clean and build
   ./Scripts/build.sh --clean
   ```

   **Option B: Xcode (Traditional)**
   ```bash
   open AeroSpaceBar.xcodeproj
   ```

   **Option C: xcodebuild (Command Line)**
   ```bash
   # Build Debug
   xcodebuild -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -configuration Debug build

   # Build Release
   xcodebuild -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -configuration Release build
   ```

3. **Build and Run**
    - **Scripts**: Build artifacts are in `build/AeroSpaceBar/Build/Products/Release/AeroSpaceBar.app`
    - **Xcode**: Select your target device (Mac), press `Cmd + R` or click the Run button
    - **xcodebuild**: Run the built app from `build/AeroSpaceBar/Build/Products/[Configuration]/AeroSpaceBar.app`
    - The app will appear in your menu bar

#### Option 2: Download Release

1. Go to the [Releases page](https://github.com/rdrkr/aerospacebar-app/releases)
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
    - Configure visual themes, transparency, and appearance options
    - Set up per-space or per-group visual customization
    - Configure TOML config file path and automatic updates
    - Access advanced settings for logging, performance, and behavior controls

## 🔄 Software Updates

AeroSpaceBar uses [Sparkle 2](https://sparkle-project.org/) for automatic software updates. Updates are distributed via
GitHub Releases and tracked through an appcast XML file.

### For End Users

The app automatically checks for updates periodically. You can also:

- **Configure automatic updates** in Settings → Advanced → Software Updates
- **Manually check for updates** via the app menu or settings
- **Enable automatic downloads** to have updates ready to install

Updates are signed with EdDSA signatures to ensure authenticity and security.

### For Developers

#### Initial Setup

1. **Generate EdDSA Signing Keys**

   Sparkle uses EdDSA keys to sign updates and verify their authenticity. Generate these keys once:

   ```bash
   # Download Sparkle tools from https://github.com/sparkle-project/Sparkle/releases/latest
   # Extract and run:
   ./Sparkle-2.x.x/bin/generate_keys
   ```

   This outputs:
    - A **private key** (keep this SECRET and secure!)
    - A **public key** (set as environment variable)

2. **Store Credentials**

   **Option A: macOS Keychain (Recommended for Local Development)**

   Store your credentials securely in macOS Keychain:

   ```bash
   # Store Sparkle private key
   security add-generic-password \
     -s "sparkle-private-key" \
     -a "sparkle" \
     -w "YOUR_SPARKLE_PRIVATE_KEY_HERE"

   # Store GitHub token
   security add-generic-password \
     -s "github-token" \
     -a "github" \
     -w "YOUR_GITHUB_TOKEN_HERE"
   ```

   **Benefits:**
   - ✅ More secure - credentials encrypted by macOS
   - ✅ Persistent across terminal sessions
   - ✅ No need to export environment variables
   - ✅ Automatic access control by macOS

   **Option B: GitHub Secrets (Required for CI/CD)**

   For automated releases via GitHub Actions, configure these secrets in your **private development repository**:

   **Required Secrets:**

   | Secret                  | Description                                                            |
   |-------------------------|------------------------------------------------------------------------|
   | `CERTIFICATES_P12`      | Base64-encoded Apple Developer ID Application certificate (P12 format) |
   | `CERTIFICATES_PASSWORD` | Password used when exporting the P12 certificate                       |
   | `NOTARIZATION_APPLE_ID` | Your Apple Developer account email                                     |
   | `NOTARIZATION_PASSWORD` | App-specific password from appleid.apple.com                           |
   | `NOTARIZATION_TEAM_ID`  | Your Apple Developer Team ID (10-character code)                       |
   | `SPARKLE_PRIVATE_KEY`   | Sparkle EdDSA private key for signing updates                          |
   | `PUBLIC_REPO_TOKEN`     | GitHub Personal Access Token with `repo` scope                         |

   **How to obtain each secret:**

   <details>
   <summary><strong>CERTIFICATES_P12</strong> - Apple Developer ID Certificate</summary>

   ```bash
   base64 -i ~/Desktop/certificate.p12 | pbcopy
   rm ~/Desktop/certificate.p12
   ```

   Export from Keychain Access → My Certificates → "Developer ID Application: Your Name" → Export

   </details>

   <details>
   <summary><strong>NOTARIZATION_PASSWORD</strong> - App-Specific Password</summary>

   1. Go to https://appleid.apple.com
   2. Sign in and navigate to "App-Specific Passwords"
   3. Generate password for "AeroSpaceBar Notarization"
   4. Copy the generated password (format: xxxx-xxxx-xxxx-xxxx)

   Check if you have it in keychain:
   ```bash
   security find-generic-password -s "notarization-password" -w 2>/dev/null
   security find-generic-password -s "AC_PASSWORD" -w 2>/dev/null
   ```

   </details>

   <details>
   <summary><strong>NOTARIZATION_TEAM_ID</strong> - Apple Developer Team ID</summary>

   ```bash
   security find-identity -v -p codesigning | grep "Apple Development"
   ```

   Look for the 10-character code in parentheses, e.g., (ABCDE12345)

   Or visit: https://developer.apple.com/account → Membership

   </details>

   <details>
   <summary><strong>SPARKLE_PRIVATE_KEY</strong> - Update Signing Key</summary>

   From keychain:
   ```bash
   security find-generic-password -l "Private key for signing Sparkle updates" -w 2>/dev/null
   ```

   Or generate new keys:
   ```bash
   ./Sparkle-2.x.x/bin/generate_keys
   ```

   ⚠️ **IMPORTANT**: If you generate new keys, update `SUPublicEDKey` in Info.plist

   </details>

   <details>
   <summary><strong>PUBLIC_REPO_TOKEN</strong> - GitHub Token</summary>

   1. Go to https://github.com/settings/tokens
   2. Generate new token (classic)
   3. Name: "AeroSpaceBar Release Automation"
   4. Scopes: `repo`, `workflow`
   5. Copy token (starts with ghp_...)

   Check if you have it in keychain:
   ```bash
   security find-generic-password -s "aerospacebar-app-github-token" -w 2>/dev/null
   ```

   </details>

   **Setting up secrets:**

   1. Go to https://github.com/rdrkr/AeroSpaceBar
   2. Click Settings → Secrets and variables → Actions
   3. Click "New repository secret"
   4. Add each secret with the exact name from the table above

   **Security Notes:**
   - ⚠️ Never commit secrets to your repository
   - 🔒 GitHub encrypts secrets and masks them in logs
   - 🔒 Secrets are only available to GitHub Actions, not forks

   **Note**: Release scripts check **macOS Keychain first**, then fall back to environment variables. This means local development uses Keychain while CI/CD uses GitHub Secrets automatically.

#### Creating a Release

##### Quick Start: Automated Scripts

The fastest way to create a release is using the automated release scripts:

```bash
# 1. Prepare the release interactively
./Scripts/prepare-release.sh

# 2. Run the complete automated release
./Scripts/release.sh
```

**What the automated workflow does:**

- ✅ Validates pre-flight checks (git status, tools, certificates)
- 🔨 Builds the app (Release configuration)
- ✍️ Code signs with proper Sparkle entitlements
- 🍎 Submits to Apple notarization
- 📦 Creates DMG and ZIP archives
- 🚀 Creates GitHub release in public repository
- 📋 Updates and validates appcast.xml
- 📤 Pushes appcast to public repository

##### Automated Release (GitHub Actions)

1. Update CHANGELOG.md with release notes for your version

2. Bump version and commit:
   ```bash
   ./Scripts/bump-version.sh 1.0.1
   git add AeroSpaceBar.xcodeproj/project.pbxproj CHANGELOG.md
   git commit -m "chore :: bump version to 1.0.1"
   ```

3. Create and push a version tag:
   ```bash
   git tag -a v1.0.1 -m "Release version 1.0.1"
   git push origin v1.0.1
   ```

4. The GitHub Actions workflow automatically:
    - Builds the release version
    - Code signs and notarizes the app
    - Creates ZIP and DMG archives
    - Generates a GitHub Release in [aerospacebar-app](https://github.com/rdrkr/aerospacebar-app/releases)
    - Updates the appcast.xml file
    - Signs the update with EdDSA signature

##### Manual Release (Using Scripts)

1. Prepare and validate:
   ```bash
   ./Scripts/prepare-release.sh 1.0.1
   ```

2. Build and sign:
   ```bash
   ./Scripts/build.sh --clean
   ./Scripts/sign-and-notarize.sh build/AeroSpaceBar/Build/Products/Release/AeroSpaceBar.app
   ```

3. Create distribution files:
   ```bash
   ./Scripts/create-dmg.sh build/AeroSpaceBar/Build/Products/Release/AeroSpaceBar.app
   cd build/AeroSpaceBar/Build/Products/Release && ditto -c -k --keepParent AeroSpaceBar.app ../../../../AeroSpaceBar-v1.0.1.zip
   ```

4. Create GitHub release and update appcast:
   ```bash
   # Create release using gh CLI
   gh release create v1.0.1 \
     --repo rdrkr/aerospacebar-app \
     --title "AeroSpaceBar 1.0.1" \
     --notes-file CHANGELOG.md \
     AeroSpaceBar-v1.0.1.zip

   # Update appcast
   ./Scripts/update-appcast.sh 1.0.1 AeroSpaceBar-v1.0.1.zip ../aerospacebar-app/appcast.xml
   ```

##### Available Release Scripts

All scripts are in the `Scripts/` directory:

**Version Management:**

- `version.sh` - Get current version and build number from Xcode project
- `bump-version.sh` - Bump version in Xcode project settings
- `extract-build-number.sh` - Extract build number from app bundle

**Build & Quality:**

- `build.sh` - Build app using xcodebuild
- `preflight-check.sh` - Validate release readiness

**Code Signing & Distribution:**

- `codesign-app.sh` - Code sign app with proper entitlements
- `notarize-app.sh` - Submit to Apple notarization
- `sign-and-notarize.sh` - Combined signing and notarization workflow
- `create-dmg.sh` - Create distributable DMG files

**Sparkle Updates:**

- `generate-appcast.sh` - Generate appcast.xml from GitHub releases
- `update-appcast.sh` - Update appcast with new release
- `verify-appcast.sh` - Validate appcast XML structure
- `changelog-to-html.sh` - Convert CHANGELOG.md to HTML

**Release Workflow:**

- `prepare-release.sh` - Interactive release preparation
- `release.sh` - Complete automated release workflow

#### Appcast Feed URL

The app checks for updates at:

```
https://raw.githubusercontent.com/rdrkr/aerospacebar-app/main/appcast.xml
```

#### Troubleshooting Updates

**Updates Not Appearing:**

- Check that the version in appcast.xml is higher than the current version
- Verify the SUFeedURL in Info.plist is correct
- Check that appcast.xml is accessible at the configured URL
- Look for Sparkle logs in Console.app (filter for "Sparkle" or "SUUpdater")

**Signature Verification Failed:**

- Ensure the public key environment variable matches your private key
- Verify the signature in appcast.xml was generated correctly
- Make sure you're signing the correct ZIP file

**Build Issues:**

- Clean and rebuild: `./Scripts/build.sh --clean`
- Or use xcodebuild directly: `xcodebuild clean build -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar`

## 🎮 Usage

### Basic Operations

- **View Spaces**: Click the menu bar icon to see all available spaces
- **Switch Spaces**: Click on any space to focus it
- **View Windows**: Hover over a space to see its windows
- **Focus Windows**: Click on any window to bring it to focus
- **Manage Groups**: Organize spaces into custom groups with configurable ranges
- **Toggle Features**: Enable/disable empty spaces, window titles, and performance metrics
- **Customize Themes**: Apply theme presets or customize individual space visual properties
- **Monitor Config**: Automatic TOML configuration file monitoring and reload

### Menu Bar Interface

The menu bar displays:

- 🎯 **Current Space**: Shows the currently focused space
- 📊 **Space Count**: Number of total spaces (with empty space toggle)
- ⚡ **Status Indicator**: Shows if AeroSpace is running
- 👥 **Groups Display**: Shows configured space groups (when enabled)
- 🎨 **Dynamic Theming**: Adapts to system wallpaper, menu bar visibility, with theme presets and per-space customization

### App Control Menu

The menubar icon provides:

- ⚙️ **Settings...** (`Cmd + ,`): Open comprehensive settings window
    - **General**: Basic appearance and behavior settings
    - **Groups**: Configure menu bar applications group organization and per-group visual customization
    - **Spaces**: Configure per-space visual properties and appearance
    - **Advanced**: Theme presets, TOML configuration, and software update settings
    - **Developer**: Advanced logging, performance metrics, and feature flags
    - **License**: License management and activation
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

### Architecture Layers

The project follows Clean Architecture with three main layers:

- **Domain Layer** (`Packages/Domain`): Core business logic, entities, use cases, and gateway contracts with no external
  dependencies
- **Data Layer** (`Packages/Data`): Repository implementations, data models, network clients, and AeroSpace CLI
  integration
- **Presentation Layer** (`Packages/Presentation`): MVVM ViewModels using Combine, SwiftUI Views, and app resources

### Test Coverage

- **DomainTests**: Entity, gateway, and use case tests for business logic validation
- **DataTests**: Repository, network client, and data layer integration tests
- **PresentationTests**: ViewModel and presentation layer unit tests
- **PresentationUITests**: End-to-end user interface and interaction tests

### Code Style

- **SwiftLint**: Follows SwiftLint rules for consistent code style
- **SwiftFormat**: Automated code formatting with `.swiftformat` configuration
- **Documentation**: All public APIs are documented using Swift documentation markup
- **Naming**: Follows Swift naming conventions
- **Architecture**: Strict adherence to Clean Architecture principles
- **SOLID Principles**: Strict adherence to SOLID principles

### Build System

AeroSpaceBar uses **xcodebuild** with Swift Package Manager for building:

#### Build Scripts (Recommended)

Use the provided build scripts for common tasks:

```bash
# Build commands
./Scripts/build.sh                     # Build Release configuration
./Scripts/build.sh -c Debug            # Build Debug configuration
./Scripts/build.sh --clean             # Clean and build
./Scripts/build.sh --skip-signing      # Build without signing check
```

#### Xcode Commands

Direct xcodebuild commands are also available:

```bash
# Build project
xcodebuild -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -configuration Release build

# Build Debug
xcodebuild -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -configuration Debug build

# Clean build artifacts
xcodebuild -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar clean

# Run tests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar
```

#### Automatic Code Quality Checks

The Xcode project includes a **pre-build script** that automatically runs before every build:

1. **SwiftFormat** (pass 1) - Format code
2. **SwiftLint --fix** - Auto-fix linting issues
3. **SwiftFormat** (pass 2) - Ensure formatting after fixes
4. **SwiftLint lint --strict** - Validate code quality

**Important**:

- If linting fails, the build will fail
- Make sure SwiftFormat and SwiftLint are installed: `brew install swiftformat swiftlint`
- The script automatically detects Homebrew installation (supports both Intel and Apple Silicon Macs)

To **disable for Debug builds** (optional), you can modify the Run Script Phase in Xcode to skip these checks for faster
iteration during development.

### Dependencies

The project uses modern Swift Package Manager dependencies:

- **[TOMLKit](https://github.com/LebJe/TOMLKit)**: TOML configuration file parsing for AeroSpace configuration files
- **[AsyncFileMonitor](https://github.com/rdrkr/AsyncFileMonitor)**: Async file monitoring for configuration file
  changes
- **[Sparkle](https://github.com/sparkle-project/Sparkle)**: Software update framework for automatic updates
- **[ModifiedCopyMacro](https://github.com/WilhelmOks/ModifiedCopyMacro)**: Swift macro for immutable copy modifications
- **AppIntents.framework**: Native macOS framework for app integration and metadata extraction
- **Standard macOS Frameworks**: SwiftUI, Combine, AppKit for native system integration

### Linting & Formatting

- SwiftFormat configuration: `.swiftformat` (120 char line limit, 4-space indentation)
- SwiftLint configuration: `.swiftlint.yaml` (extensive opt-in rules, analyzer rules)
- Run locally:
    - `swiftformat .` to format the codebase
    - `swiftlint` to report style issues
    - `swiftlint --fix` to auto-fix fixable issues
- **Note**: SwiftFormat and SwiftLint must be installed separately (`brew install swiftformat swiftlint`)
- **Note**: Configurations are aligned to prevent conflicts

## 🧪 Testing

### Running Tests

#### Using xcodebuild

```bash
# Run all tests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar

# Run specific test targets
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:DomainTests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:DataTests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:PresentationTests
xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar -only-testing:PresentationUITests
```

#### Using Xcode IDE

You can also run tests directly from Xcode:

1. Open `AeroSpaceBar.xcodeproj`
2. Press `Cmd + U` to run all tests
3. Or use the Test Navigator (`Cmd + 6`) to run specific tests

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
4. **Ensure all tests pass and code is formatted**
   ```bash
   # Format and lint
   swiftformat .
   swiftlint --fix

   # Build and test
   ./Scripts/build.sh --clean
   xcodebuild test -project AeroSpaceBar.xcodeproj -scheme AeroSpaceBar
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

## 🙏 Acknowledgments

- **[AeroSpace](https://github.com/nikitabobko/aerospace)**: The amazing window manager that makes this possible
  support
- **[VibeMeter](https://github.com/steipete/VibeMeter)**: Inspiration for build and release automation scripts
- **[Clean Architecture MVVM](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)**: Architecture inspiration and
  guidelines
- **[SwiftUI](https://developer.apple.com/xcode/swiftui/)**: Modern UI framework from Apple
- **[Combine](https://developer.apple.com/documentation/combine)**: Reactive programming framework
- **[TOMLKit](https://github.com/LebJe/TOMLKit)**: TOML parsing library for AeroSpace configuration files
- **[AsyncFileMonitor](https://github.com/rdrkr/AsyncFileMonitor)**: Async file monitoring for configuration changes
- **[Sparkle](https://github.com/sparkle-project/Sparkle)**: Software update framework
- **[ModifiedCopyMacro](https://github.com/WilhelmOks/ModifiedCopyMacro)**: Swift macro for immutable modifications

## 📞 Support

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/rdrkr/AeroSpaceBar/issues)
- **Discussions**: [GitHub Discussions](https://github.com/rdrkr/AeroSpaceBar/discussions)

---

<div align="center">

**Made with ❤️ by [Ronen Druker](https://github.com/rdrkr)**

[⭐ Star this repo](https://github.com/rdrkr/AeroSpaceBar/stargazers) | [🐛 Report a bug](https://github.com/rdrkr/AeroSpaceBar/issues) | [💡 Request a feature](https://github.com/rdrkr/AeroSpaceBar/issues/new)

</div>
