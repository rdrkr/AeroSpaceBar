# Changelog

All notable changes to AeroSpaceBar will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Transitioned project to open source under AGPL v3 license
- Consolidated from multi-repo to single-repo architecture
- Disabled licensing/paywall - all features now freely available
- Updated Sparkle feed URL and release workflow for single-repo setup











## [1.0.0] - 2026-09-04

### Added

- migrate to AeroSpace event subscription API
- added optional hidden spaces

### Fixed

- report expired signing certificates in release workflow
- detect Developer ID certificate when signing releases
- resolve Xcode icon and package dependency warnings
- break retain cycles in ViewModel and repository subscriptions


## [1.0.0-beta.13] - 2026-04-15

### Added

- cover empty-space and last-window-closed edge cases

### Changed

- updated README.md badges


## [1.0.0-beta.12] - 2026-04-05

### Fixed

- restore menu bar click-through for Apple button and file menus


## [1.0.0-beta.11] - 2026-04-05

### Added

- added foreground group tint effect


## [1.0.0-beta.10] - 2026-03-27

### Fixed

- align SpacesContainerView leading edge with wallpaper background


## [1.0.0-beta.9] - 2026-03-12

### Fixed

- animations not applied when apps updated


## [1.0.0-beta.8] - 2026-03-11

### Fixed

- incorrect groups hide condition


## [1.0.0-beta.7] - 2026-03-11


## [1.0.0-beta.6] - 2026-03-11

### Added

- added a customizable quick hide keybind trigger
- added apple button background option

### Fixed

- replace ForEach group views with animated Canvas to fix vertical positioning bug


## [1.0.0-beta.5] - 2026-03-09

### Changed

- open source transition - single repo, disable paywall


## [1.0.0-beta.2] - 2026-02-17

### Added

- added lemon-squeezy integration
- added software update
- added optional screen sharing permission handling
- added theme selection mode
- added toml config file instead of UserDefaults
- added per space visual configurable properties
- added app licensing
- added groups appearance gloabl and spaces modes
- added menu bar groups widget
- added option to show empty spaces
- added hide functionality to match system menu bar hidden state
- added hide spaces with global keybind
- added appearance settings

### Changed

- add comprehensive test infrastructure and implementation
- removed license api key related logic
- license related types and clean code
- cleaned up IntoForm construction
- scrollable functionality from LazyVStackList
- replace DispatchQueue usage with modern Tasks
- consolidated group, window, and space logic
- changed project structure for better dependency management
- added confirmation promp to reset all settings
- code cleanup and re-org of presentation layer
- organized domain use cases
- improved presentation according to swiftui best practices

### Fixed

- resolved settings layout issues with scrolling
- incorrect group indexing handling

## [1.0.0-beta.3] - 2026-02-17

## [1.0.0-beta.4] - 2026-02-17
