// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import SwiftUI

/// Protocol defining the interface for configuration operations.
///
/// This protocol provides a contract for repositories that manage application configuration,
/// allowing for easy testing and dependency injection. It belongs to the domain layer
/// and defines the business requirements for configuration operations.
/// Following reactive patterns similar to Kotlin Flow/StateFlow.
@MainActor
public protocol ConfigurationGateway {
    // MARK: - Publishers for Reactive Data Flow

    /// Publisher that emits show window titles updates.
    var showWindowTitlesPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits AeroSpace path updates.
    var aeroSpacePathPublisher: AnyPublisher<String, Never> { get }

    /// Publisher that emits focus window on click updates.
    var focusWindowOnClickPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits show empty spaces updates.
    var showEmptySpacesPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits show groups updates.
    var showGroupsPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits enable performance metrics updates.
    var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits optimized performance enabled updates.
    var isOptimizedPerformanceEnabledPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits log level updates.
    var logLevelPublisher: AnyPublisher<Logger.Level, Never> { get }

    /// Publisher that emits AeroSpace version updates.
    var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> { get }

    // MARK: - UI Configuration Publishers

    /// Publisher that emits menu bar vertical padding updates.
    var menuBarVerticalPaddingPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits menu bar horizontal padding updates.
    var menuBarHorizontalPaddingPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits widget spacing updates.
    var widgetSpacingPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits animation duration updates.
    var animationDurationPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits window icon size updates.
    var windowIconSizePublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits spaces configuration updates.
    var spacesVisualConfigPublisher: AnyPublisher<[VisualContainer], Never> { get }

    /// Publisher that emits spaces appearance mode updates.
    var spacesAppearanceModePublisher: AnyPublisher<SpacesAppearanceMode, Never> { get }

    /// Publisher that emits global space visual configuration updates.
    var globalSpacesVisualConfigPublisher: AnyPublisher<VisualContainer, Never> { get }

    /// Publisher that emits group configuration updates.
    var groupsPublisher: AnyPublisher<[Domain.Group], Never> { get }

    /// Publisher that emits groups appearance mode updates.
    var groupsAppearanceModePublisher: AnyPublisher<GroupsAppearanceMode, Never> { get }

    /// Publisher that emits global groups visual configuration updates.
    var globalGroupsVisualConfigPublisher: AnyPublisher<VisualContainer, Never> { get }

    // MARK: - Async Setters (trigger updates via publishers)

    /// Sets whether to show window titles in the interface.
    /// - Parameter value: Whether to show window titles
    func setShowWindowTitles(_ value: Bool) async

    /// Sets the absolute path to the AeroSpace binary.
    /// - Parameter path: The path, or empty to clear
    func setAeroSpacePath(_ path: String) async

    /// Sets whether to focus a window when clicking on it.
    /// - Parameter value: Whether to focus window on click
    func setFocusWindowOnClick(_ value: Bool) async

    /// Sets whether to show empty spaces in the interface.
    /// - Parameter value: Whether to show empty spaces
    func setShowEmptySpaces(_ value: Bool) async

    /// Sets whether to show groups in the interface.
    /// - Parameter value: Whether to show groups
    func setShowGroups(_ value: Bool) async

    /// Sets whether to enable performance metrics collection.
    /// - Parameter value: Whether to enable performance metrics
    func setEnablePerformanceMetrics(_ value: Bool) async

    /// Sets whether to enable optimized performance behavior.
    /// - Parameter value: Whether to enable optimized performance
    func setIsOptimizedPerformanceEnabled(_ value: Bool) async

    /// Sets the current log level for application logging.
    /// - Parameter level: The log level
    func setLogLevel(_ level: Logger.Level) async

    // MARK: - UI Configuration Async Setters

    /// Sets the vertical padding for the menu bar interface in points.
    /// - Parameter value: The vertical padding
    func setMenuBarVerticalPadding(_ value: Double) async

    /// Sets the horizontal padding for the menu bar interface in points.
    /// - Parameter value: The horizontal padding
    func setMenuBarHorizontalPadding(_ value: Double) async

    /// Sets the spacing between widgets in the menu bar in points.
    /// - Parameter value: The widget spacing
    func setWidgetSpacing(_ value: Double) async

    /// Sets the animation duration in seconds.
    /// - Parameter value: The animation duration
    func setAnimationDuration(_ value: Double) async

    /// Sets the size of window icons in points.
    /// - Parameter value: The window icon size
    func setWindowIconSize(_ value: Double) async

    /// Sets the spaces configuration for organizing spaces.
    /// - Parameter value: The spaces configuration
    func setSpacesVisualConfig(_ value: [VisualContainer]) async

    /// Sets the spaces appearance mode.
    /// - Parameter value: The spaces appearance mode
    func setSpacesAppearanceMode(_ value: SpacesAppearanceMode) async

    /// Sets the global groups visual configuration.
    /// - Parameter value: The global groups visual configuration
    func setGlobalGroupsVisualConfig(_ value: VisualContainer) async

    /// Sets the group configuration for organizing menu bar applications.
    /// - Parameter value: The group configuration
    func setGroups(_ value: [Domain.Group]) async

    /// Sets the groups appearance mode.
    /// - Parameter value: The groups appearance mode
    func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) async

    /// Sets the global space visual configuration.
    /// - Parameter value: The global space visual configuration
    func setGlobalSpacesVisualConfig(_ value: VisualContainer) async

    // MARK: - AeroSpace Configuration Management

    /// Opens the AeroSpace configuration file.
    /// If no config file exists, creates a default one.
    func openAeroSpaceConfig() async

    /// Gets the AeroSpace configuration file path.
    /// - Returns: The AeroSpace configuration file path
    func getAeroSpaceConfigPath() async -> URL

    // MARK: - Configuration Management

    /// Resets all configuration settings to their default values.
    func resetToDefaults() async
}
