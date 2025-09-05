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
protocol ConfigurationGateway {
    // MARK: - Publishers for Reactive Data Flow

    /// Publisher that emits show window titles updates.
    var showWindowTitlesPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits AeroSpace path updates.
    var aeroSpacePathPublisher: AnyPublisher<String, Never> { get }

    /// Publisher that emits focus window on click updates.
    var focusWindowOnClickPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits show empty spaces updates.
    var showEmptySpacesPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits enable performance metrics updates.
    var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits optimized performance enabled updates.
    var isOptimizedPerformanceEnabledPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits log level updates.
    var logLevelPublisher: AnyPublisher<Logger.Level, Never> { get }

    /// Publisher that emits AeroSpace version updates.
    var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> { get }

    // MARK: - UI Configuration Publishers

    /// Publisher that emits space background opacity updates.
    var spaceBackgroundOpacityPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits space background blur radius updates.
    var spaceBackgroundBlurRadiusPublisher: AnyPublisher<CGFloat, Never> { get }

    /// Publisher that emits space background tint color updates.
    var spaceBackgroundTintColorPublisher: AnyPublisher<Color, Never> { get }

    /// Publisher that emits space foreground color updates.
    var spaceForegroundColorPublisher: AnyPublisher<Color, Never> { get }

    /// Publisher that emits space border tint color updates.
    var spaceBorderTintColorPublisher: AnyPublisher<Color, Never> { get }

    /// Publisher that emits space border opacity updates.
    var spaceBorderOpacityPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits space border width updates.
    var spaceBorderWidthPublisher: AnyPublisher<CGFloat, Never> { get }

    /// Publisher that emits menu bar vertical padding updates.
    var menuBarVerticalPaddingPublisher: AnyPublisher<CGFloat, Never> { get }

    /// Publisher that emits menu bar horizontal padding updates.
    var menuBarHorizontalPaddingPublisher: AnyPublisher<CGFloat, Never> { get }

    /// Publisher that emits widget spacing updates.
    var widgetSpacingPublisher: AnyPublisher<CGFloat, Never> { get }

    /// Publisher that emits animation duration updates.
    var animationDurationPublisher: AnyPublisher<Double, Never> { get }

    /// Publisher that emits window icon size updates.
    var windowIconSizePublisher: AnyPublisher<CGFloat, Never> { get }

    /// Publisher that emits space corner radius updates.
    var spaceCornerRadiusPublisher: AnyPublisher<CGFloat, Never> { get }

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

    /// Sets the background opacity level of the space elements.
    /// - Parameter value: The space background opacity level
    func setSpaceBackgroundOpacity(_ value: Double) async

    /// Sets the background blur radius for space elements in points.
    /// - Parameter value: The space background blur radius
    func setSpaceBackgroundBlurRadius(_ value: CGFloat) async

    /// Sets the background tint color for space elements.
    /// - Parameter value: The space background tint color
    func setSpaceBackgroundTintColor(_ value: Color) async

    /// Sets the foreground color for space elements.
    /// - Parameter value: The space foreground color
    func setSpaceForegroundColor(_ value: Color) async

    /// Sets the border tint color for space elements.
    /// - Parameter value: The space border tint color
    func setSpaceBorderTintColor(_ value: Color) async

    /// Sets the border opacity level of the space elements.
    /// - Parameter value: The space border opacity level
    func setSpaceBorderOpacity(_ value: Double) async

    /// Sets the border width for space elements in points.
    /// - Parameter value: The space border width
    func setSpaceBorderWidth(_ value: CGFloat) async

    /// Sets the vertical padding for the menu bar interface in points.
    /// - Parameter value: The vertical padding
    func setMenuBarVerticalPadding(_ value: CGFloat) async

    /// Sets the horizontal padding for the menu bar interface in points.
    /// - Parameter value: The horizontal padding
    func setMenuBarHorizontalPadding(_ value: CGFloat) async

    /// Sets the spacing between widgets in the menu bar in points.
    /// - Parameter value: The widget spacing
    func setWidgetSpacing(_ value: CGFloat) async

    /// Sets the animation duration in seconds.
    /// - Parameter value: The animation duration
    func setAnimationDuration(_ value: Double) async

    /// Sets the size of window icons in points.
    /// - Parameter value: The window icon size
    func setWindowIconSize(_ value: CGFloat) async

    /// Sets the corner radius for space elements in points.
    /// - Parameter value: The space corner radius
    func setSpaceCornerRadius(_ value: CGFloat) async

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
