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

    /// Publisher that emits show foreground overlay updates.
    var showForegroundOverlayPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits enable performance metrics updates.
    var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits optimized performance enabled updates.
    var isOptimizedPerformanceEnabledPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits log level updates.
    var logLevelPublisher: AnyPublisher<Logger.Level, Never> { get }

    /// Publisher that emits AeroSpace version updates.
    var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> { get }

    /// Publisher that emits config file path updates.
    var configFilePathPublisher: AnyPublisher<String, Never> { get }

    /// Publisher that emits whether the user has been asked for screen capture permissions.
    var hasAskedForScreenCapturePermissionsPublisher: AnyPublisher<Bool, Never> { get }

    // MARK: - UI Configuration Publishers

    /// Publisher that emits spaces configuration updates.
    var spacesColorPropertiesPublisher: AnyPublisher<[ColorProperties], Never> { get }

    /// Publisher that emits spaces geometric properties updates.
    var spacesGeometricPropertiesPublisher: AnyPublisher<[GeometricProperties], Never> { get }

    /// Publisher that emits spaces effect properties updates.
    var spacesEffectPropertiesPublisher: AnyPublisher<[EffectProperties], Never> { get }

    /// Publisher that emits spaces appearance mode updates.
    var spacesAppearanceModePublisher: AnyPublisher<SpacesAppearanceMode, Never> { get }

    /// Publisher that emits global space color properties updates.
    var globalSpacesColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> { get }

    /// Publisher that emits global space geometric properties updates.
    var globalSpacesGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> { get }

    /// Publisher that emits global space effect properties updates.
    var globalSpacesEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> { get }

    /// Publisher that emits show Apple Button as space updates.
    var showAppleButtonAsSpacePublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits Apple Button color properties updates.
    var appleButtonColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> { get }

    /// Publisher that emits Apple Button geometric properties updates.
    var appleButtonGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> { get }

    /// Publisher that emits Apple Button effect properties updates.
    var appleButtonEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> { get }

    /// Publisher that emits group configuration updates.
    var groupsPublisher: AnyPublisher<[Domain.Group], Never> { get }

    /// Publisher that emits groups appearance mode updates.
    var groupsAppearanceModePublisher: AnyPublisher<GroupsAppearanceMode, Never> { get }

    /// Publisher that emits global groups color properties updates.
    var globalGroupsColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> { get }

    /// Publisher that emits global groups geometric properties updates.
    var globalGroupsGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> { get }

    /// Publisher that emits global groups effect properties updates.
    var globalGroupsEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> { get }

    /// Publisher that emits theme mode updates.
    var themeModePublisher: AnyPublisher<ThemeMode, Never> { get }

    /// Publisher that emits theme preset updates.
    var themePresetColorPropertiesPublisher: AnyPublisher<ThemePresetColorProperties, Never> { get }

    /// Publisher that emits theme preset geometric properties updates.
    var themePresetGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> { get }

    /// Publisher that emits theme preset effect properties updates.
    var themePresetEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> { get }

    /// Publisher that emits Quick Hide enabled state updates.
    var quickHideEnabledPublisher: AnyPublisher<Bool, Never> { get }

    /// Publisher that emits Quick Hide trigger key updates.
    var quickHideTriggerKeyPublisher: AnyPublisher<QuickHideTriggerKey, Never> { get }

    // MARK: - Async Setters (trigger updates via publishers)

    func setShowWindowTitles(_ value: Bool) async

    func setAeroSpacePath(_ path: String) async

    func setFocusWindowOnClick(_ value: Bool) async

    func setShowEmptySpaces(_ value: Bool) async

    func setShowGroups(_ value: Bool) async

    func setShowForegroundOverlay(_ value: Bool) async

    func setEnablePerformanceMetrics(_ value: Bool) async

    func setIsOptimizedPerformanceEnabled(_ value: Bool) async

    func setLogLevel(_ level: Logger.Level) async

    func setConfigFilePath(_ path: String) async

    func setHasAskedForScreenCapturePermissions(_ value: Bool) async

    // MARK: - UI Configuration Async Setters

    func setSpacesColorProperties(_ value: [ColorProperties]) async

    func setSpacesGeometricProperties(_ value: [GeometricProperties]) async

    func setSpacesEffectProperties(_ value: [EffectProperties]) async

    func setSpacesAppearanceMode(_ value: SpacesAppearanceMode) async

    func setGlobalGroupsColorProperties(_ value: ColorProperties) async

    func setGroups(_ value: [Domain.Group]) async

    func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) async

    func setGlobalSpacesColorProperties(_ value: ColorProperties) async

    func setGlobalSpacesGeometricProperties(_ value: GeometricProperties) async

    func setGlobalSpacesEffectProperties(_ value: EffectProperties) async

    func setShowAppleButtonAsSpace(_ value: Bool) async

    func setAppleButtonColorProperties(_ value: ColorProperties) async

    func setAppleButtonGeometricProperties(_ value: GeometricProperties) async

    func setAppleButtonEffectProperties(_ value: EffectProperties) async

    func setGlobalGroupsGeometricProperties(_ value: GeometricProperties) async

    func setGlobalGroupsEffectProperties(_ value: EffectProperties) async

    func setThemeMode(_ value: ThemeMode) async

    func setThemePresetColorProperties(_ value: ThemePresetColorProperties) async

    func setThemePresetGeometricProperties(_ value: GeometricProperties) async

    func setThemePresetEffectProperties(_ value: EffectProperties) async

    func setQuickHideEnabled(_ value: Bool) async

    func setQuickHideTriggerKey(_ value: QuickHideTriggerKey) async

    // MARK: - AeroSpace Configuration Management

    func openAeroSpaceConfig() async

    func getAeroSpaceConfigPath() async -> URL

    func getConfigFilePath() -> String

    func openConfigFile() async

    // MARK: - Configuration Management

    /// Resets all configuration settings to their default values.
    func resetToDefaults() async
}
