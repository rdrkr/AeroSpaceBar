// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
@testable import Domain
import Foundation
@testable import Presentation
import WebKit

// MARK: - Mock Gateways

final class MockFeatureFlagsGateway: FeatureFlagsGateway {
    private let subject: CurrentValueSubject<FeatureFlags, Never>

    var lastFlags: FeatureFlags?
    var resetCalled = false

    init(flags: FeatureFlags) {
        subject = CurrentValueSubject(flags)
    }

    var featureFlagsPublisher: AnyPublisher<FeatureFlags, Never> {
        subject.eraseToAnyPublisher()
    }

    func setFeatureFlags(_ flags: FeatureFlags) {
        lastFlags = flags
        subject.send(flags)
    }

    func resetToDefaults() {
        resetCalled = true
    }
}

// MARK: - MockSoftwareUpdateGateway

final class MockSoftwareUpdateGateway: SoftwareUpdateGateway {
    // MARK: - Subjects

    private let automaticCheckForUpdatesEnabledSubject = CurrentValueSubject<Bool, Never>(true)
    private let automaticDownloadUpdatesEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let lastUpdateCheckDateSubject = CurrentValueSubject<Date?, Never>(nil)

    // MARK: - Publishers

    var automaticCheckForUpdatesEnabledPublisher: AnyPublisher<Bool, Never> {
        automaticCheckForUpdatesEnabledSubject.eraseToAnyPublisher()
    }

    var automaticDownloadUpdatesEnabledPublisher: AnyPublisher<Bool, Never> {
        automaticDownloadUpdatesEnabledSubject.eraseToAnyPublisher()
    }

    var lastUpdateCheckDatePublisher: AnyPublisher<Date?, Never> {
        lastUpdateCheckDateSubject.eraseToAnyPublisher()
    }

    // MARK: - Methods

    func setAutomaticCheckForUpdatesEnabled(_ enabled: Bool) {
        automaticCheckForUpdatesEnabledSubject.send(enabled)
    }

    func setAutomaticDownloadUpdatesEnabled(_ enabled: Bool) {
        automaticDownloadUpdatesEnabledSubject.send(enabled)
    }

    func checkForUpdates() {
        lastUpdateCheckDateSubject.send(Date())
    }
}

final class MockLicenseGateway: LicenseGateway {
    private let licenseInfoSubject: CurrentValueSubject<LicenseInfo, Never>
    private let enableLicensingSubject: CurrentValueSubject<Bool, Never>
    private let enableTrialRequestSubject: CurrentValueSubject<Bool, Never>

    #if DEBUG
        private let mockActiveLicenseSubject: CurrentValueSubject<Bool, Never>
        private let checkoutEnvironmentSubject: CurrentValueSubject<CheckoutEnvironment, Never>
    #endif

    var lastUserName: String?
    var lastProfileImageData: Data?
    var activationResult: LicenseInfo?
    var activationError: Error?
    var trialHasBeenUsed = false

    init(
        licenseInfo: LicenseInfo = LicenseInfo(
            licenseKey: "",
            licenseStatus: .unknown,
            userName: "",
            email: ""
        ),
        enableLicensing: Bool = false,
        enableTrialRequest: Bool = false,
        mockActiveLicense: Bool = false,
        checkoutEnvironment: CheckoutEnvironment = .production
    ) {
        licenseInfoSubject = CurrentValueSubject(licenseInfo)
        enableLicensingSubject = CurrentValueSubject(enableLicensing)
        enableTrialRequestSubject = CurrentValueSubject(enableTrialRequest)
        #if DEBUG
            mockActiveLicenseSubject = CurrentValueSubject(mockActiveLicense)
            checkoutEnvironmentSubject = CurrentValueSubject(checkoutEnvironment)
        #endif
    }

    var licenseInfoPublisher: AnyPublisher<LicenseInfo, Never> {
        licenseInfoSubject.eraseToAnyPublisher()
    }

    var enableLicensingPublisher: AnyPublisher<Bool, Never> {
        enableLicensingSubject.eraseToAnyPublisher()
    }

    var enableTrialRequestPublisher: AnyPublisher<Bool, Never> {
        enableTrialRequestSubject.eraseToAnyPublisher()
    }

    #if DEBUG
        var mockActiveLicensePublisher: AnyPublisher<Bool, Never> {
            mockActiveLicenseSubject.eraseToAnyPublisher()
        }

        var checkoutEnvironmentPublisher: AnyPublisher<CheckoutEnvironment, Never> {
            checkoutEnvironmentSubject.eraseToAnyPublisher()
        }
    #endif

    func activateLicense(_ licenseKey: String) throws -> LicenseInfo {
        if let error = activationError {
            throw error
        }
        let result = activationResult ?? LicenseInfo(
            licenseKey: licenseKey,
            licenseStatus: .licensed,
            userName: "Test User",
            email: "test@example.com"
        )
        licenseInfoSubject.send(result)
        return result
    }

    func deactivateLicense() throws {
        let info = LicenseInfo(
            licenseKey: "",
            licenseStatus: .unknown,
            userName: "",
            email: ""
        )
        licenseInfoSubject.send(info)
    }

    func requestTrial() throws {
        if trialHasBeenUsed {
            throw LicenseError.trialAlreadyUsed
        }
    }

    func getCheckoutURL() -> URL {
        guard let url = URL(string: "https://example.com/checkout") else {
            fatalError("Invalid checkout URL")
        }

        return url
    }

    func getTrialCheckoutURL() -> URL {
        guard let url = URL(string: "https://example.com/trial-checkout") else {
            fatalError("Invalid trial checkout URL")
        }

        return url
    }

    func setEnableLicensing(_ enabled: Bool) {
        enableLicensingSubject.send(enabled)
    }

    func setEnableTrialRequest(_ enabled: Bool) {
        enableTrialRequestSubject.send(enabled)
    }

    #if DEBUG
        func setMockActiveLicense(_ active: Bool) {
            mockActiveLicenseSubject.send(active)
        }

        func setCheckoutEnvironment(_ environment: CheckoutEnvironment) {
            checkoutEnvironmentSubject.send(environment)
        }
    #endif

    func updateLicenseInfo(_ info: LicenseInfo) {
        licenseInfoSubject.send(info)
    }

    func resetLicenseFeatureFlags() {
        // Mock implementation
    }

    func setUserName(_ userName: String) {
        lastUserName = userName
    }

    func setProfileImageData(_ profileImageData: Data?) {
        lastProfileImageData = profileImageData
    }

    func hasTrialBeenUsed() -> Bool {
        trialHasBeenUsed
    }

    func handleCheckoutSuccess(licenseKey _: String) {
        // Mock implementation
    }
}

final class MockSystemMenuBarGateway: SystemMenuBarGateway {
    private let menuBarHeightSubject: CurrentValueSubject<Double, Never>
    private let menuBarAppsSubject: CurrentValueSubject<[MenuBarApp], Never>
    private let menuBarVisibilitySubject: CurrentValueSubject<Bool, Never>
    private let screenCapturePermissionGrantedSubject: CurrentValueSubject<Bool, Never>
    private let wallpaperSubject: CurrentValueSubject<NSImage?, Never>

    init(
        menuBarHeight: Double = 39.0,
        menuBarApps: [MenuBarApp] = [],
        menuBarVisibility: Bool = true,
        screenCapturePermissionGranted: Bool = false,
        wallpaper: NSImage? = nil
    ) {
        menuBarHeightSubject = CurrentValueSubject(menuBarHeight)
        menuBarAppsSubject = CurrentValueSubject(menuBarApps)
        menuBarVisibilitySubject = CurrentValueSubject(menuBarVisibility)
        screenCapturePermissionGrantedSubject = CurrentValueSubject(screenCapturePermissionGranted)
        wallpaperSubject = CurrentValueSubject(wallpaper)
    }

    var wallpaperPublisher: AnyPublisher<NSImage?, Never> {
        wallpaperSubject.eraseToAnyPublisher()
    }

    var menuBarHeightPublisher: AnyPublisher<Double, Never> {
        menuBarHeightSubject.eraseToAnyPublisher()
    }

    var menuBarVisibilityPublisher: AnyPublisher<Bool, Never> {
        menuBarVisibilitySubject.eraseToAnyPublisher()
    }

    var menuBarAppsPublisher: AnyPublisher<[MenuBarApp], Never> {
        menuBarAppsSubject.eraseToAnyPublisher()
    }

    var screenCapturePermissionGrantedPublisher: AnyPublisher<Bool, Never> {
        screenCapturePermissionGrantedSubject.eraseToAnyPublisher()
    }

    func requestScreenCapturePermissions() {
        // Mock implementation
    }

    func setWallpaper(_ wallpaper: NSImage?) {
        wallpaperSubject.send(wallpaper)
    }

    func setMenuBarVisibility(_ visible: Bool) {
        menuBarVisibilitySubject.send(visible)
    }

    func setMenuBarHeight(_ height: Double) {
        menuBarHeightSubject.send(height)
    }

    func setMenuBarApps(_ apps: [MenuBarApp]) {
        menuBarAppsSubject.send(apps)
    }

    func setScreenCapturePermissionGranted(_ granted: Bool) {
        screenCapturePermissionGrantedSubject.send(granted)
    }
}

final class MockConfigurationGateway: ConfigurationGateway {
    // Publishers
    private let showWindowTitlesSubject = CurrentValueSubject<Bool, Never>(true)
    private let aeroSpacePathSubject = CurrentValueSubject<String, Never>("/usr/local/bin/aerospace")
    private let focusWindowOnClickSubject = CurrentValueSubject<Bool, Never>(false)
    private let showEmptySpacesSubject = CurrentValueSubject<Bool, Never>(true)
    private let hiddenSpacesSubject = CurrentValueSubject<[String], Never>([])
    private let showGroupsSubject = CurrentValueSubject<Bool, Never>(true)
    private let enablePerformanceMetricsSubject = CurrentValueSubject<Bool, Never>(false)
    private let isOptimizedPerformanceEnabledSubject = CurrentValueSubject<Bool, Never>(true)
    private let logLevelSubject = CurrentValueSubject<Logger.Level, Never>(.info)
    private let currentAeroSpaceVersionSubject = CurrentValueSubject<String?, Never>("v1.0.0")
    private let configFilePathSubject = CurrentValueSubject<String, Never>("~/.config/aerospacebar/aerospacebar.toml")
    private let hasAskedForScreenCapturePermissionsSubject = CurrentValueSubject<Bool, Never>(false)
    private let spacesColorPropertiesSubject = CurrentValueSubject<[ColorProperties], Never>([])
    private let spacesGeometricPropertiesSubject = CurrentValueSubject<[GeometricProperties], Never>([])
    private let spacesEffectPropertiesSubject = CurrentValueSubject<[EffectProperties], Never>([])
    private let spacesAppearanceModeSubject = CurrentValueSubject<SpacesAppearanceMode, Never>(.allSpaces)
    private let globalSpacesColorPropertiesSubject = CurrentValueSubject<ColorProperties, Never>(ColorProperties())
    private let globalSpacesGeometricPropertiesSubject = CurrentValueSubject<
        GeometricProperties,
        Never
    >(GeometricProperties())
    private let globalSpacesEffectPropertiesSubject = CurrentValueSubject<EffectProperties, Never>(EffectProperties())
    private let groupsSubject = CurrentValueSubject<[Domain.Group], Never>(Domain.Group.singleGroup)
    private let groupsAppearanceModeSubject = CurrentValueSubject<GroupsAppearanceMode, Never>(.matchSpaces)
    private let globalGroupsColorPropertiesSubject = CurrentValueSubject<ColorProperties, Never>(ConfigurationDefaults
        .groupsGlobalColorProperties)
    private let globalGroupsGeometricPropertiesSubject = CurrentValueSubject<
        GeometricProperties,
        Never
    >(GeometricProperties())
    private let globalGroupsEffectPropertiesSubject = CurrentValueSubject<EffectProperties, Never>(EffectProperties())
    private let themeModeSubject = CurrentValueSubject<ThemeMode, Never>(.preset)
    private let themePresetColorPropertiesSubject = CurrentValueSubject<
        ThemePresetColorProperties,
        Never
    >(.catppuccinMocha)
    private let themePresetGeometricPropertiesSubject = CurrentValueSubject<
        GeometricProperties,
        Never
    >(GeometricProperties())
    private let themePresetEffectPropertiesSubject = CurrentValueSubject<EffectProperties, Never>(EffectProperties())
    private let quickHideEnabledSubject = CurrentValueSubject<Bool, Never>(true)
    private let quickHideTriggerKeySubject = CurrentValueSubject<QuickHideTriggerKey, Never>(.fn)
    private let automaticCheckForUpdatesEnabledSubject = CurrentValueSubject<Bool, Never>(true)
    private let automaticDownloadUpdatesEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let lastUpdateCheckDateSubject = CurrentValueSubject<Date?, Never>(nil)

    /// Test Accessors
    var lastShowGroups: Bool {
        showGroupsSubject.value
    }

    var lastGroups: [Domain.Group] {
        groupsSubject.value
    }

    var lastGroupsAppearanceMode: GroupsAppearanceMode {
        groupsAppearanceModeSubject.value
    }

    /// Publisher Accessors
    var showWindowTitlesPublisher: AnyPublisher<Bool, Never> {
        showWindowTitlesSubject.eraseToAnyPublisher()
    }

    var aeroSpacePathPublisher: AnyPublisher<String, Never> {
        aeroSpacePathSubject.eraseToAnyPublisher()
    }

    var focusWindowOnClickPublisher: AnyPublisher<Bool, Never> {
        focusWindowOnClickSubject.eraseToAnyPublisher()
    }

    var showEmptySpacesPublisher: AnyPublisher<Bool, Never> {
        showEmptySpacesSubject.eraseToAnyPublisher()
    }

    var hiddenSpacesPublisher: AnyPublisher<[String], Never> {
        hiddenSpacesSubject.eraseToAnyPublisher()
    }

    var showGroupsPublisher: AnyPublisher<Bool, Never> {
        showGroupsSubject.eraseToAnyPublisher()
    }

    var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> {
        enablePerformanceMetricsSubject.eraseToAnyPublisher()
    }

    var isOptimizedPerformanceEnabledPublisher: AnyPublisher<Bool, Never> {
        isOptimizedPerformanceEnabledSubject.eraseToAnyPublisher()
    }

    var logLevelPublisher: AnyPublisher<Logger.Level, Never> {
        logLevelSubject.eraseToAnyPublisher()
    }

    var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> {
        currentAeroSpaceVersionSubject.eraseToAnyPublisher()
    }

    var configFilePathPublisher: AnyPublisher<String, Never> {
        configFilePathSubject.eraseToAnyPublisher()
    }

    var hasAskedForScreenCapturePermissionsPublisher: AnyPublisher<Bool, Never> {
        hasAskedForScreenCapturePermissionsSubject.eraseToAnyPublisher()
    }

    var spacesColorPropertiesPublisher: AnyPublisher<[ColorProperties], Never> {
        spacesColorPropertiesSubject.eraseToAnyPublisher()
    }

    var spacesGeometricPropertiesPublisher: AnyPublisher<[GeometricProperties], Never> {
        spacesGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    var spacesEffectPropertiesPublisher: AnyPublisher<[EffectProperties], Never> {
        spacesEffectPropertiesSubject.eraseToAnyPublisher()
    }

    var spacesAppearanceModePublisher: AnyPublisher<SpacesAppearanceMode, Never> {
        spacesAppearanceModeSubject.eraseToAnyPublisher()
    }

    var globalSpacesColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> {
        globalSpacesColorPropertiesSubject.eraseToAnyPublisher()
    }

    var globalSpacesGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        globalSpacesGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    var globalSpacesEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        globalSpacesEffectPropertiesSubject.eraseToAnyPublisher()
    }

    var groupsPublisher: AnyPublisher<[Domain.Group], Never> {
        groupsSubject.eraseToAnyPublisher()
    }

    var groupsAppearanceModePublisher: AnyPublisher<GroupsAppearanceMode, Never> {
        groupsAppearanceModeSubject.eraseToAnyPublisher()
    }

    var globalGroupsColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> {
        globalGroupsColorPropertiesSubject.eraseToAnyPublisher()
    }

    var globalGroupsGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        globalGroupsGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    var globalGroupsEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        globalGroupsEffectPropertiesSubject.eraseToAnyPublisher()
    }

    var themeModePublisher: AnyPublisher<ThemeMode, Never> {
        themeModeSubject.eraseToAnyPublisher()
    }

    var themePresetColorPropertiesPublisher: AnyPublisher<ThemePresetColorProperties, Never> {
        themePresetColorPropertiesSubject.eraseToAnyPublisher()
    }

    var themePresetGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        themePresetGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    var themePresetEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        themePresetEffectPropertiesSubject.eraseToAnyPublisher()
    }

    var quickHideEnabledPublisher: AnyPublisher<Bool, Never> {
        quickHideEnabledSubject.eraseToAnyPublisher()
    }

    var quickHideTriggerKeyPublisher: AnyPublisher<QuickHideTriggerKey, Never> {
        quickHideTriggerKeySubject.eraseToAnyPublisher()
    }

    var automaticCheckForUpdatesEnabledPublisher: AnyPublisher<Bool, Never> {
        automaticCheckForUpdatesEnabledSubject.eraseToAnyPublisher()
    }

    var automaticDownloadUpdatesEnabledPublisher: AnyPublisher<Bool, Never> {
        automaticDownloadUpdatesEnabledSubject.eraseToAnyPublisher()
    }

    var lastUpdateCheckDatePublisher: AnyPublisher<Date?, Never> {
        lastUpdateCheckDateSubject.eraseToAnyPublisher()
    }

    /// Methods
    func setShowWindowTitles(_ value: Bool) {
        showWindowTitlesSubject.send(value)
    }

    func setAeroSpacePath(_ path: String) {
        aeroSpacePathSubject.send(path)
    }

    func setFocusWindowOnClick(_ value: Bool) {
        focusWindowOnClickSubject.send(value)
    }

    func setShowEmptySpaces(_ value: Bool) {
        showEmptySpacesSubject.send(value)
    }

    func setHiddenSpaces(_ value: [String]) {
        hiddenSpacesSubject.send(value)
    }

    func setShowGroups(_ value: Bool) {
        showGroupsSubject.send(value)
    }

    func setEnablePerformanceMetrics(_ value: Bool) {
        enablePerformanceMetricsSubject.send(value)
    }

    func setIsOptimizedPerformanceEnabled(_ value: Bool) {
        isOptimizedPerformanceEnabledSubject.send(value)
    }

    func setLogLevel(_ level: Logger.Level) {
        logLevelSubject.send(level)
    }

    func setConfigFilePath(_ path: String) {
        configFilePathSubject.send(path)
    }

    func setHasAskedForScreenCapturePermissions(_ value: Bool) {
        hasAskedForScreenCapturePermissionsSubject.send(value)
    }

    func setSpacesColorProperties(_ value: [ColorProperties]) {
        spacesColorPropertiesSubject.send(value)
    }

    func setSpacesGeometricProperties(_ value: [GeometricProperties]) {
        spacesGeometricPropertiesSubject.send(value)
    }

    func setSpacesEffectProperties(_ value: [EffectProperties]) {
        spacesEffectPropertiesSubject.send(value)
    }

    func setSpacesAppearanceMode(_ value: SpacesAppearanceMode) {
        spacesAppearanceModeSubject.send(value)
    }

    func updateSpacesAppearanceMode(_ value: SpacesAppearanceMode) {
        spacesAppearanceModeSubject.send(value)
    }

    func setGlobalSpacesColorProperties(_ value: ColorProperties) {
        globalSpacesColorPropertiesSubject.send(value)
    }

    func setGlobalSpacesGeometricProperties(_ value: GeometricProperties) {
        globalSpacesGeometricPropertiesSubject.send(value)
    }

    func setGlobalSpacesEffectProperties(_ value: EffectProperties) {
        globalSpacesEffectPropertiesSubject.send(value)
    }

    func setGroups(_ value: [Domain.Group]) {
        groupsSubject.send(value)
    }

    func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) {
        groupsAppearanceModeSubject.send(value)
    }

    func setGlobalGroupsColorProperties(_ value: ColorProperties) {
        globalGroupsColorPropertiesSubject.send(value)
    }

    func setGlobalGroupsGeometricProperties(_ value: GeometricProperties) {
        globalGroupsGeometricPropertiesSubject.send(value)
    }

    func setGlobalGroupsEffectProperties(_ value: EffectProperties) {
        globalGroupsEffectPropertiesSubject.send(value)
    }

    func setThemeMode(_ value: ThemeMode) {
        themeModeSubject.send(value)
    }

    func setThemePresetColorProperties(_ value: ThemePresetColorProperties) {
        themePresetColorPropertiesSubject.send(value)
    }

    func setThemePresetGeometricProperties(_ value: GeometricProperties) {
        themePresetGeometricPropertiesSubject.send(value)
    }

    func setThemePresetEffectProperties(_ value: EffectProperties) {
        themePresetEffectPropertiesSubject.send(value)
    }

    func setQuickHideEnabled(_ value: Bool) {
        quickHideEnabledSubject.send(value)
    }

    func setQuickHideTriggerKey(_ value: QuickHideTriggerKey) {
        quickHideTriggerKeySubject.send(value)
    }

    func setAutomaticCheckForUpdatesEnabled(_ value: Bool) {
        automaticCheckForUpdatesEnabledSubject.send(value)
    }

    func setAutomaticDownloadUpdatesEnabled(_ value: Bool) {
        automaticDownloadUpdatesEnabledSubject.send(value)
    }

    func checkForUpdates() { }
    func openAeroSpaceConfig() { }
    func getAeroSpaceConfigPath() -> URL {
        URL(fileURLWithPath: "/tmp/aerospace.toml")
    }

    func getConfigFilePath() -> String {
        configFilePathSubject.value
    }

    func openConfigFile() { }
    func resetToDefaults() { }
}

final class MockKeyboardShortcutsGateway: KeyboardShortcutsGateway {
    private let quickHideTriggerKeyPressStateSubject: CurrentValueSubject<Bool, Never>

    init(quickHideTriggerKeyPressState: Bool = false) {
        quickHideTriggerKeyPressStateSubject = CurrentValueSubject(quickHideTriggerKeyPressState)
    }

    /// Backward compatibility init
    init(isPressed: Bool) {
        quickHideTriggerKeyPressStateSubject = CurrentValueSubject(isPressed)
    }

    var quickHideTriggerKeyPressStatePublisher: AnyPublisher<Bool, Never> {
        quickHideTriggerKeyPressStateSubject.eraseToAnyPublisher()
    }

    func emitQuickHideTriggerKeyPressState(_ pressed: Bool) {
        quickHideTriggerKeyPressStateSubject.send(pressed)
    }
}
