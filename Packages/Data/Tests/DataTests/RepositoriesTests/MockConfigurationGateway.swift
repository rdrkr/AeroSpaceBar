// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
import Data
@testable import Domain
import Foundation

/// Mock implementation of ConfigurationGateway for testing.
@MainActor
public final class MockConfigurationGateway: ConfigurationGateway {
    // MARK: - Call Tracking

    public private(set) var setShowWindowTitlesCalls: [Bool] = []
    public private(set) var setAeroSpacePathCalls: [String] = []
    public private(set) var setFocusWindowOnClickCalls: [Bool] = []
    public private(set) var setShowEmptySpacesCalls: [Bool] = []
    public private(set) var setShowGroupsCalls: [Bool] = []
    public private(set) var setEnablePerformanceMetricsCalls: [Bool] = []
    public private(set) var setIsOptimizedPerformanceEnabledCalls: [Bool] = []
    public private(set) var setLogLevelCalls: [Logger.Level] = []
    public private(set) var setConfigFilePathCalls: [String] = []
    public private(set) var setHasAskedForScreenCapturePermissionsCalls: [Bool] = []
    public private(set) var setSpacesColorPropertiesCalls: [[ColorProperties]] = []
    public private(set) var setSpacesGeometricPropertiesCalls: [[GeometricProperties]] = []
    public private(set) var setSpacesEffectPropertiesCalls: [[EffectProperties]] = []
    public private(set) var setSpacesAppearanceModeCalls: [SpacesAppearanceMode] = []
    public private(set) var setGlobalSpacesColorPropertiesCalls: [ColorProperties] = []
    public private(set) var setGlobalSpacesGeometricPropertiesCalls: [GeometricProperties] = []
    public private(set) var setGlobalSpacesEffectPropertiesCalls: [EffectProperties] = []
    public private(set) var setGroupsCalls: [[Domain.Group]] = []
    public private(set) var setGroupsAppearanceModeCalls: [GroupsAppearanceMode] = []
    public private(set) var setGlobalGroupsColorPropertiesCalls: [ColorProperties] = []
    public private(set) var setGlobalGroupsGeometricPropertiesCalls: [GeometricProperties] = []
    public private(set) var setGlobalGroupsEffectPropertiesCalls: [EffectProperties] = []
    public private(set) var setThemeModeCalls: [ThemeMode] = []
    public private(set) var setThemePresetColorPropertiesCalls: [ThemePresetColorProperties] = []
    public private(set) var setThemePresetGeometricPropertiesCalls: [GeometricProperties] = []
    public private(set) var setThemePresetEffectPropertiesCalls: [EffectProperties] = []
    public private(set) var openAeroSpaceConfigCalls: Int = 0
    public private(set) var getAeroSpaceConfigPathCalls: Int = 0
    public private(set) var getConfigFilePathCalls: Int = 0
    public private(set) var openConfigFileCalls: Int = 0
    public private(set) var resetToDefaultsCalls: Int = 0

    // MARK: - Configurable Values

    public var showWindowTitlesToEmit: Bool = false
    public var aeroSpacePathToEmit: String = "/opt/homebrew/bin/aerospace"
    public var focusWindowOnClickToEmit: Bool = true
    public var showEmptySpacesToEmit: Bool = false
    public var showGroupsToEmit: Bool = false
    public var enablePerformanceMetricsToEmit: Bool = false
    public var isOptimizedPerformanceEnabledToEmit: Bool = true
    public var logLevelToEmit: Logger.Level = .info
    public var currentAeroSpaceVersionToEmit: String? = "v0.13.0"
    public var configFilePathToEmit: String = "~/.aerospace.toml"
    public var hasAskedForScreenCapturePermissionsToEmit: Bool = false
    public var spacesColorPropertiesToEmit: [ColorProperties] = []
    public var spacesGeometricPropertiesToEmit: [GeometricProperties] = []
    public var spacesEffectPropertiesToEmit: [EffectProperties] = []
    public var spacesAppearanceModeToEmit: SpacesAppearanceMode = .allSpaces
    public var globalSpacesColorPropertiesToEmit = ConfigurationDefaults.spaceColorProperties
    public var globalSpacesGeometricPropertiesToEmit = GeometricProperties()
    public var globalSpacesEffectPropertiesToEmit = EffectProperties()
    public var groupsToEmit: [Domain.Group] = []
    public var groupsAppearanceModeToEmit: GroupsAppearanceMode = .allGroups
    public var globalGroupsColorPropertiesToEmit = ConfigurationDefaults.groupsGlobalColorProperties
    public var globalGroupsGeometricPropertiesToEmit = GeometricProperties()
    public var globalGroupsEffectPropertiesToEmit = EffectProperties()
    public var themeModeToEmit: ThemeMode = .preset
    public var themePresetColorPropertiesToEmit = ConfigurationDefaults.themePresetColorProperties
    public var themePresetGeometricPropertiesToEmit = GeometricProperties()
    public var themePresetEffectPropertiesToEmit = EffectProperties()
    public var aeroSpaceConfigPathToReturn = URL(fileURLWithPath: "/Users/test/.aerospace.toml")

    // MARK: - Subjects

    private let showWindowTitlesSubject: CurrentValueSubject<Bool, Never>
    private let aeroSpacePathSubject: CurrentValueSubject<String, Never>
    private let focusWindowOnClickSubject: CurrentValueSubject<Bool, Never>
    private let showEmptySpacesSubject: CurrentValueSubject<Bool, Never>
    private let showGroupsSubject: CurrentValueSubject<Bool, Never>
    private let enablePerformanceMetricsSubject: CurrentValueSubject<Bool, Never>
    private let isOptimizedPerformanceEnabledSubject: CurrentValueSubject<Bool, Never>
    private let logLevelSubject: CurrentValueSubject<Logger.Level, Never>
    private let currentAeroSpaceVersionSubject: CurrentValueSubject<String?, Never>
    private let configFilePathSubject: CurrentValueSubject<String, Never>
    private let hasAskedForScreenCapturePermissionsSubject: CurrentValueSubject<Bool, Never>
    private let spacesColorPropertiesSubject: CurrentValueSubject<[ColorProperties], Never>
    private let spacesGeometricPropertiesSubject: CurrentValueSubject<[GeometricProperties], Never>
    private let spacesEffectPropertiesSubject: CurrentValueSubject<[EffectProperties], Never>
    private let spacesAppearanceModeSubject: CurrentValueSubject<SpacesAppearanceMode, Never>
    private let globalSpacesColorPropertiesSubject: CurrentValueSubject<ColorProperties, Never>
    private let globalSpacesGeometricPropertiesSubject: CurrentValueSubject<GeometricProperties, Never>
    private let globalSpacesEffectPropertiesSubject: CurrentValueSubject<EffectProperties, Never>
    private let groupsSubject: CurrentValueSubject<[Domain.Group], Never>
    private let groupsAppearanceModeSubject: CurrentValueSubject<GroupsAppearanceMode, Never>
    private let globalGroupsColorPropertiesSubject: CurrentValueSubject<ColorProperties, Never>
    private let globalGroupsGeometricPropertiesSubject: CurrentValueSubject<GeometricProperties, Never>
    private let globalGroupsEffectPropertiesSubject: CurrentValueSubject<EffectProperties, Never>
    private let themeModeSubject: CurrentValueSubject<ThemeMode, Never>
    private let themePresetColorPropertiesSubject: CurrentValueSubject<ThemePresetColorProperties, Never>
    private let themePresetGeometricPropertiesSubject: CurrentValueSubject<GeometricProperties, Never>
    private let themePresetEffectPropertiesSubject: CurrentValueSubject<EffectProperties, Never>

    // MARK: - Initialization

    public init() {
        showWindowTitlesSubject = CurrentValueSubject(showWindowTitlesToEmit)
        aeroSpacePathSubject = CurrentValueSubject(aeroSpacePathToEmit)
        focusWindowOnClickSubject = CurrentValueSubject(focusWindowOnClickToEmit)
        showEmptySpacesSubject = CurrentValueSubject(showEmptySpacesToEmit)
        showGroupsSubject = CurrentValueSubject(showGroupsToEmit)
        enablePerformanceMetricsSubject = CurrentValueSubject(enablePerformanceMetricsToEmit)
        isOptimizedPerformanceEnabledSubject = CurrentValueSubject(isOptimizedPerformanceEnabledToEmit)
        logLevelSubject = CurrentValueSubject(logLevelToEmit)
        currentAeroSpaceVersionSubject = CurrentValueSubject(currentAeroSpaceVersionToEmit)
        configFilePathSubject = CurrentValueSubject(configFilePathToEmit)
        hasAskedForScreenCapturePermissionsSubject = CurrentValueSubject(hasAskedForScreenCapturePermissionsToEmit)
        spacesColorPropertiesSubject = CurrentValueSubject(spacesColorPropertiesToEmit)
        spacesGeometricPropertiesSubject = CurrentValueSubject(spacesGeometricPropertiesToEmit)
        spacesEffectPropertiesSubject = CurrentValueSubject(spacesEffectPropertiesToEmit)
        spacesAppearanceModeSubject = CurrentValueSubject(spacesAppearanceModeToEmit)
        globalSpacesColorPropertiesSubject = CurrentValueSubject(globalSpacesColorPropertiesToEmit)
        globalSpacesGeometricPropertiesSubject = CurrentValueSubject(globalSpacesGeometricPropertiesToEmit)
        globalSpacesEffectPropertiesSubject = CurrentValueSubject(globalSpacesEffectPropertiesToEmit)
        groupsSubject = CurrentValueSubject(groupsToEmit)
        groupsAppearanceModeSubject = CurrentValueSubject(groupsAppearanceModeToEmit)
        globalGroupsColorPropertiesSubject = CurrentValueSubject(globalGroupsColorPropertiesToEmit)
        globalGroupsGeometricPropertiesSubject = CurrentValueSubject(globalGroupsGeometricPropertiesToEmit)
        globalGroupsEffectPropertiesSubject = CurrentValueSubject(globalGroupsEffectPropertiesToEmit)
        themeModeSubject = CurrentValueSubject(themeModeToEmit)
        themePresetColorPropertiesSubject = CurrentValueSubject(themePresetColorPropertiesToEmit)
        themePresetGeometricPropertiesSubject = CurrentValueSubject(themePresetGeometricPropertiesToEmit)
        themePresetEffectPropertiesSubject = CurrentValueSubject(themePresetEffectPropertiesToEmit)
    }

    // MARK: - Publishers

    public var showWindowTitlesPublisher: AnyPublisher<Bool, Never> {
        showWindowTitlesSubject.eraseToAnyPublisher()
    }

    public var aeroSpacePathPublisher: AnyPublisher<String, Never> {
        aeroSpacePathSubject.eraseToAnyPublisher()
    }

    public var focusWindowOnClickPublisher: AnyPublisher<Bool, Never> {
        focusWindowOnClickSubject.eraseToAnyPublisher()
    }

    public var showEmptySpacesPublisher: AnyPublisher<Bool, Never> {
        showEmptySpacesSubject.eraseToAnyPublisher()
    }

    public var showGroupsPublisher: AnyPublisher<Bool, Never> {
        showGroupsSubject.eraseToAnyPublisher()
    }

    public var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> {
        enablePerformanceMetricsSubject.eraseToAnyPublisher()
    }

    public var isOptimizedPerformanceEnabledPublisher: AnyPublisher<Bool, Never> {
        isOptimizedPerformanceEnabledSubject.eraseToAnyPublisher()
    }

    public var logLevelPublisher: AnyPublisher<Logger.Level, Never> {
        logLevelSubject.eraseToAnyPublisher()
    }

    public var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> {
        currentAeroSpaceVersionSubject.eraseToAnyPublisher()
    }

    public var configFilePathPublisher: AnyPublisher<String, Never> {
        configFilePathSubject.eraseToAnyPublisher()
    }

    public var hasAskedForScreenCapturePermissionsPublisher: AnyPublisher<Bool, Never> {
        hasAskedForScreenCapturePermissionsSubject.eraseToAnyPublisher()
    }

    public var spacesColorPropertiesPublisher: AnyPublisher<[ColorProperties], Never> {
        spacesColorPropertiesSubject.eraseToAnyPublisher()
    }

    public var spacesGeometricPropertiesPublisher: AnyPublisher<[GeometricProperties], Never> {
        spacesGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    public var spacesEffectPropertiesPublisher: AnyPublisher<[EffectProperties], Never> {
        spacesEffectPropertiesSubject.eraseToAnyPublisher()
    }

    public var spacesAppearanceModePublisher: AnyPublisher<SpacesAppearanceMode, Never> {
        spacesAppearanceModeSubject.eraseToAnyPublisher()
    }

    public var globalSpacesColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> {
        globalSpacesColorPropertiesSubject.eraseToAnyPublisher()
    }

    public var globalSpacesGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        globalSpacesGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    public var globalSpacesEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        globalSpacesEffectPropertiesSubject.eraseToAnyPublisher()
    }

    public var groupsPublisher: AnyPublisher<[Domain.Group], Never> {
        groupsSubject.eraseToAnyPublisher()
    }

    public var groupsAppearanceModePublisher: AnyPublisher<GroupsAppearanceMode, Never> {
        groupsAppearanceModeSubject.eraseToAnyPublisher()
    }

    public var globalGroupsColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> {
        globalGroupsColorPropertiesSubject.eraseToAnyPublisher()
    }

    public var globalGroupsGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        globalGroupsGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    public var globalGroupsEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        globalGroupsEffectPropertiesSubject.eraseToAnyPublisher()
    }

    public var themeModePublisher: AnyPublisher<ThemeMode, Never> {
        themeModeSubject.eraseToAnyPublisher()
    }

    public var themePresetColorPropertiesPublisher: AnyPublisher<ThemePresetColorProperties, Never> {
        themePresetColorPropertiesSubject.eraseToAnyPublisher()
    }

    public var themePresetGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        themePresetGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    public var themePresetEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        themePresetEffectPropertiesSubject.eraseToAnyPublisher()
    }

    // MARK: - Async Setters

    public func setShowWindowTitles(_ value: Bool) {
        setShowWindowTitlesCalls.append(value)
        showWindowTitlesSubject.send(value)
    }

    public func setAeroSpacePath(_ path: String) {
        setAeroSpacePathCalls.append(path)
        aeroSpacePathSubject.send(path)
    }

    public func setFocusWindowOnClick(_ value: Bool) {
        setFocusWindowOnClickCalls.append(value)
        focusWindowOnClickSubject.send(value)
    }

    public func setShowEmptySpaces(_ value: Bool) {
        setShowEmptySpacesCalls.append(value)
        showEmptySpacesSubject.send(value)
    }

    public func setShowGroups(_ value: Bool) {
        setShowGroupsCalls.append(value)
        showGroupsSubject.send(value)
    }

    public func setEnablePerformanceMetrics(_ value: Bool) {
        setEnablePerformanceMetricsCalls.append(value)
        enablePerformanceMetricsSubject.send(value)
    }

    public func setIsOptimizedPerformanceEnabled(_ value: Bool) {
        setIsOptimizedPerformanceEnabledCalls.append(value)
        isOptimizedPerformanceEnabledSubject.send(value)
    }

    public func setLogLevel(_ level: Logger.Level) {
        setLogLevelCalls.append(level)
        logLevelSubject.send(level)
    }

    public func setConfigFilePath(_ path: String) {
        setConfigFilePathCalls.append(path)
        configFilePathSubject.send(path)
    }

    public func setHasAskedForScreenCapturePermissions(_ value: Bool) {
        setHasAskedForScreenCapturePermissionsCalls.append(value)
        hasAskedForScreenCapturePermissionsSubject.send(value)
    }

    public func setSpacesColorProperties(_ value: [ColorProperties]) {
        setSpacesColorPropertiesCalls.append(value)
        spacesColorPropertiesSubject.send(value)
    }

    public func setSpacesGeometricProperties(_ value: [GeometricProperties]) {
        setSpacesGeometricPropertiesCalls.append(value)
        spacesGeometricPropertiesSubject.send(value)
    }

    public func setSpacesEffectProperties(_ value: [EffectProperties]) {
        setSpacesEffectPropertiesCalls.append(value)
        spacesEffectPropertiesSubject.send(value)
    }

    public func setSpacesAppearanceMode(_ value: SpacesAppearanceMode) {
        setSpacesAppearanceModeCalls.append(value)
        spacesAppearanceModeSubject.send(value)
    }

    public func setGlobalSpacesColorProperties(_ value: ColorProperties) {
        setGlobalSpacesColorPropertiesCalls.append(value)
        globalSpacesColorPropertiesSubject.send(value)
    }

    public func setGlobalSpacesGeometricProperties(_ value: GeometricProperties) {
        setGlobalSpacesGeometricPropertiesCalls.append(value)
        globalSpacesGeometricPropertiesSubject.send(value)
    }

    public func setGlobalSpacesEffectProperties(_ value: EffectProperties) {
        setGlobalSpacesEffectPropertiesCalls.append(value)
        globalSpacesEffectPropertiesSubject.send(value)
    }

    public func setGlobalGroupsColorProperties(_ value: ColorProperties) {
        setGlobalGroupsColorPropertiesCalls.append(value)
        globalGroupsColorPropertiesSubject.send(value)
    }

    public func setGroups(_ value: [Domain.Group]) {
        setGroupsCalls.append(value)
        groupsSubject.send(value)
    }

    public func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) {
        setGroupsAppearanceModeCalls.append(value)
        groupsAppearanceModeSubject.send(value)
    }

    public func setGlobalGroupsGeometricProperties(_ value: GeometricProperties) {
        setGlobalGroupsGeometricPropertiesCalls.append(value)
        globalGroupsGeometricPropertiesSubject.send(value)
    }

    public func setGlobalGroupsEffectProperties(_ value: EffectProperties) {
        setGlobalGroupsEffectPropertiesCalls.append(value)
        globalGroupsEffectPropertiesSubject.send(value)
    }

    public func setThemeMode(_ value: ThemeMode) {
        setThemeModeCalls.append(value)
        themeModeSubject.send(value)
    }

    public func setThemePresetColorProperties(_ value: ThemePresetColorProperties) {
        setThemePresetColorPropertiesCalls.append(value)
        themePresetColorPropertiesSubject.send(value)
    }

    public func setThemePresetGeometricProperties(_ value: GeometricProperties) {
        setThemePresetGeometricPropertiesCalls.append(value)
        themePresetGeometricPropertiesSubject.send(value)
    }

    public func setThemePresetEffectProperties(_ value: EffectProperties) {
        setThemePresetEffectPropertiesCalls.append(value)
        themePresetEffectPropertiesSubject.send(value)
    }

    // MARK: - Configuration Management

    public func openAeroSpaceConfig() {
        openAeroSpaceConfigCalls += 1
    }

    public func getAeroSpaceConfigPath() -> URL {
        getAeroSpaceConfigPathCalls += 1
        return aeroSpaceConfigPathToReturn
    }

    public func getConfigFilePath() -> String {
        getConfigFilePathCalls += 1
        return configFilePathToEmit
    }

    public func openConfigFile() {
        openConfigFileCalls += 1
    }

    public func resetToDefaults() {
        resetToDefaultsCalls += 1
    }

    // MARK: - Test Helpers

    public func reset() {
        setShowWindowTitlesCalls.removeAll()
        setAeroSpacePathCalls.removeAll()
        setFocusWindowOnClickCalls.removeAll()
        setShowEmptySpacesCalls.removeAll()
        setShowGroupsCalls.removeAll()
        setEnablePerformanceMetricsCalls.removeAll()
        setIsOptimizedPerformanceEnabledCalls.removeAll()
        setLogLevelCalls.removeAll()
        setConfigFilePathCalls.removeAll()
        setHasAskedForScreenCapturePermissionsCalls.removeAll()
        setSpacesColorPropertiesCalls.removeAll()
        setSpacesGeometricPropertiesCalls.removeAll()
        setSpacesEffectPropertiesCalls.removeAll()
        setSpacesAppearanceModeCalls.removeAll()
        setGlobalSpacesColorPropertiesCalls.removeAll()
        setGlobalSpacesGeometricPropertiesCalls.removeAll()
        setGlobalSpacesEffectPropertiesCalls.removeAll()
        setGroupsCalls.removeAll()
        setGroupsAppearanceModeCalls.removeAll()
        setGlobalGroupsColorPropertiesCalls.removeAll()
        setGlobalGroupsGeometricPropertiesCalls.removeAll()
        setGlobalGroupsEffectPropertiesCalls.removeAll()
        setThemeModeCalls.removeAll()
        setThemePresetColorPropertiesCalls.removeAll()
        setThemePresetGeometricPropertiesCalls.removeAll()
        setThemePresetEffectPropertiesCalls.removeAll()
        openAeroSpaceConfigCalls = 0
        getAeroSpaceConfigPathCalls = 0
        getConfigFilePathCalls = 0
        openConfigFileCalls = 0
        resetToDefaultsCalls = 0
    }

    public func emitShowWindowTitles(_ value: Bool) {
        showWindowTitlesSubject.send(value)
    }

    public func emitAeroSpacePath(_ path: String) {
        aeroSpacePathSubject.send(path)
    }

    public func emitFocusWindowOnClick(_ value: Bool) {
        focusWindowOnClickSubject.send(value)
    }

    public func emitShowEmptySpaces(_ value: Bool) {
        showEmptySpacesSubject.send(value)
    }

    public func emitShowGroups(_ value: Bool) {
        showGroupsSubject.send(value)
    }

    public func emitLogLevel(_ level: Logger.Level) {
        logLevelSubject.send(level)
    }

    public func emitCurrentAeroSpaceVersion(_ version: String?) {
        currentAeroSpaceVersionSubject.send(version)
    }

    public func emitGroups(_ groups: [Domain.Group]) {
        groupsSubject.send(groups)
    }

    public func emitThemeMode(_ mode: ThemeMode) {
        themeModeSubject.send(mode)
    }
}
