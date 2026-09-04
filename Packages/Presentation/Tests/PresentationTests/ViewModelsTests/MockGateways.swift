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
        if enabled == automaticCheckForUpdatesEnabledSubject.value {
            return
        }

        automaticCheckForUpdatesEnabledSubject.send(enabled)
    }

    func setAutomaticDownloadUpdatesEnabled(_ enabled: Bool) {
        if enabled == automaticDownloadUpdatesEnabledSubject.value {
            return
        }

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
        if enabled == enableLicensingSubject.value {
            return
        }

        enableLicensingSubject.send(enabled)
    }

    func setEnableTrialRequest(_ enabled: Bool) {
        if enabled == enableTrialRequestSubject.value {
            return
        }

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
    private let appleButtonFrameSubject = CurrentValueSubject<CGRect, Never>(.zero)

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

    var appleButtonFramePublisher: AnyPublisher<CGRect, Never> {
        appleButtonFrameSubject.eraseToAnyPublisher()
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
        if wallpaper == wallpaperSubject.value {
            return
        }

        wallpaperSubject.send(wallpaper)
    }

    func setMenuBarVisibility(_ visible: Bool) {
        if visible == menuBarVisibilitySubject.value {
            return
        }

        menuBarVisibilitySubject.send(visible)
    }

    func setMenuBarHeight(_ height: Double) {
        if height == menuBarHeightSubject.value {
            return
        }

        menuBarHeightSubject.send(height)
    }

    func setMenuBarApps(_ apps: [MenuBarApp]) {
        if apps == menuBarAppsSubject.value {
            return
        }

        menuBarAppsSubject.send(apps)
    }

    func setScreenCapturePermissionGranted(_ granted: Bool) {
        if granted == screenCapturePermissionGrantedSubject.value {
            return
        }

        screenCapturePermissionGrantedSubject.send(granted)
    }
}

final class MockConfigurationGateway: ConfigurationGateway {
    // Publishers
    private let showWindowTitlesSubject = CurrentValueSubject<Bool, Never>(true)
    private let aeroSpacePathSubject = CurrentValueSubject<String, Never>("/usr/local/bin/aerospace")
    private let focusWindowOnClickSubject = CurrentValueSubject<Bool, Never>(false)
    private let showEmptySpacesSubject = CurrentValueSubject<Bool, Never>(true)
    private let showForegroundOverlaySubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.showForegroundOverlay
    )
    private let showAppleButtonAsSpaceSubject = CurrentValueSubject<Bool, Never>(
        ConfigurationDefaults.showAppleButtonAsSpace
    )
    private let appleButtonColorPropertiesSubject = CurrentValueSubject<ColorProperties, Never>(
        ConfigurationDefaults.appleButtonColorProperties
    )
    private let appleButtonGeometricPropertiesSubject = CurrentValueSubject<GeometricProperties, Never>(
        ConfigurationDefaults.appleButtonGeometricProperties
    )
    private let appleButtonEffectPropertiesSubject = CurrentValueSubject<EffectProperties, Never>(
        ConfigurationDefaults.appleButtonEffectProperties
    )
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

    var showForegroundOverlayPublisher: AnyPublisher<Bool, Never> {
        showForegroundOverlaySubject.eraseToAnyPublisher()
    }

    var showAppleButtonAsSpacePublisher: AnyPublisher<Bool, Never> {
        showAppleButtonAsSpaceSubject.eraseToAnyPublisher()
    }

    var appleButtonColorPropertiesPublisher: AnyPublisher<ColorProperties, Never> {
        appleButtonColorPropertiesSubject.eraseToAnyPublisher()
    }

    var appleButtonGeometricPropertiesPublisher: AnyPublisher<GeometricProperties, Never> {
        appleButtonGeometricPropertiesSubject.eraseToAnyPublisher()
    }

    var appleButtonEffectPropertiesPublisher: AnyPublisher<EffectProperties, Never> {
        appleButtonEffectPropertiesSubject.eraseToAnyPublisher()
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
        if value == showWindowTitlesSubject.value {
            return
        }

        showWindowTitlesSubject.send(value)
    }

    func setAeroSpacePath(_ path: String) {
        if path == aeroSpacePathSubject.value {
            return
        }

        aeroSpacePathSubject.send(path)
    }

    func setFocusWindowOnClick(_ value: Bool) {
        if value == focusWindowOnClickSubject.value {
            return
        }

        focusWindowOnClickSubject.send(value)
    }

    func setShowEmptySpaces(_ value: Bool) {
        if value == showEmptySpacesSubject.value {
            return
        }

        showEmptySpacesSubject.send(value)
    }

    func setShowForegroundOverlay(_ value: Bool) {
        if value == showForegroundOverlaySubject.value {
            return
        }

        showForegroundOverlaySubject.send(value)
    }

    func setShowAppleButtonAsSpace(_ value: Bool) {
        if value == showAppleButtonAsSpaceSubject.value {
            return
        }

        showAppleButtonAsSpaceSubject.send(value)
    }

    func setAppleButtonColorProperties(_ value: ColorProperties) {
        if value == appleButtonColorPropertiesSubject.value {
            return
        }

        appleButtonColorPropertiesSubject.send(value)
    }

    func setAppleButtonGeometricProperties(_ value: GeometricProperties) {
        if value == appleButtonGeometricPropertiesSubject.value {
            return
        }

        appleButtonGeometricPropertiesSubject.send(value)
    }

    func setAppleButtonEffectProperties(_ value: EffectProperties) {
        if value == appleButtonEffectPropertiesSubject.value {
            return
        }

        appleButtonEffectPropertiesSubject.send(value)
    }

    func setHiddenSpaces(_ value: [String]) {
        if value == hiddenSpacesSubject.value {
            return
        }

        hiddenSpacesSubject.send(value)
    }

    func setShowGroups(_ value: Bool) {
        if value == showGroupsSubject.value {
            return
        }

        showGroupsSubject.send(value)
    }

    func setEnablePerformanceMetrics(_ value: Bool) {
        if value == enablePerformanceMetricsSubject.value {
            return
        }

        enablePerformanceMetricsSubject.send(value)
    }

    func setIsOptimizedPerformanceEnabled(_ value: Bool) {
        if value == isOptimizedPerformanceEnabledSubject.value {
            return
        }

        isOptimizedPerformanceEnabledSubject.send(value)
    }

    func setLogLevel(_ level: Logger.Level) {
        if level == logLevelSubject.value {
            return
        }

        logLevelSubject.send(level)
    }

    func setConfigFilePath(_ path: String) {
        if path == configFilePathSubject.value {
            return
        }

        configFilePathSubject.send(path)
    }

    func setHasAskedForScreenCapturePermissions(_ value: Bool) {
        if value == hasAskedForScreenCapturePermissionsSubject.value {
            return
        }

        hasAskedForScreenCapturePermissionsSubject.send(value)
    }

    func setSpacesColorProperties(_ value: [ColorProperties]) {
        if value == spacesColorPropertiesSubject.value {
            return
        }

        spacesColorPropertiesSubject.send(value)
    }

    func setSpacesGeometricProperties(_ value: [GeometricProperties]) {
        if value == spacesGeometricPropertiesSubject.value {
            return
        }

        spacesGeometricPropertiesSubject.send(value)
    }

    func setSpacesEffectProperties(_ value: [EffectProperties]) {
        if value == spacesEffectPropertiesSubject.value {
            return
        }

        spacesEffectPropertiesSubject.send(value)
    }

    func setSpacesAppearanceMode(_ value: SpacesAppearanceMode) {
        if value == spacesAppearanceModeSubject.value {
            return
        }

        spacesAppearanceModeSubject.send(value)
    }

    func updateSpacesAppearanceMode(_ value: SpacesAppearanceMode) {
        spacesAppearanceModeSubject.send(value)
    }

    func setGlobalSpacesColorProperties(_ value: ColorProperties) {
        if value == globalSpacesColorPropertiesSubject.value {
            return
        }

        globalSpacesColorPropertiesSubject.send(value)
    }

    func setGlobalSpacesGeometricProperties(_ value: GeometricProperties) {
        if value == globalSpacesGeometricPropertiesSubject.value {
            return
        }

        globalSpacesGeometricPropertiesSubject.send(value)
    }

    func setGlobalSpacesEffectProperties(_ value: EffectProperties) {
        if value == globalSpacesEffectPropertiesSubject.value {
            return
        }

        globalSpacesEffectPropertiesSubject.send(value)
    }

    func setGroups(_ value: [Domain.Group]) {
        if value == groupsSubject.value {
            return
        }

        groupsSubject.send(value)
    }

    func setGroupsAppearanceMode(_ value: GroupsAppearanceMode) {
        if value == groupsAppearanceModeSubject.value {
            return
        }

        groupsAppearanceModeSubject.send(value)
    }

    func setGlobalGroupsColorProperties(_ value: ColorProperties) {
        if value == globalGroupsColorPropertiesSubject.value {
            return
        }

        globalGroupsColorPropertiesSubject.send(value)
    }

    func setGlobalGroupsGeometricProperties(_ value: GeometricProperties) {
        if value == globalGroupsGeometricPropertiesSubject.value {
            return
        }

        globalGroupsGeometricPropertiesSubject.send(value)
    }

    func setGlobalGroupsEffectProperties(_ value: EffectProperties) {
        if value == globalGroupsEffectPropertiesSubject.value {
            return
        }

        globalGroupsEffectPropertiesSubject.send(value)
    }

    func setThemeMode(_ value: ThemeMode) {
        if value == themeModeSubject.value {
            return
        }

        themeModeSubject.send(value)
    }

    func setThemePresetColorProperties(_ value: ThemePresetColorProperties) {
        if value == themePresetColorPropertiesSubject.value {
            return
        }

        themePresetColorPropertiesSubject.send(value)
    }

    func setThemePresetGeometricProperties(_ value: GeometricProperties) {
        if value == themePresetGeometricPropertiesSubject.value {
            return
        }

        themePresetGeometricPropertiesSubject.send(value)
    }

    func setThemePresetEffectProperties(_ value: EffectProperties) {
        if value == themePresetEffectPropertiesSubject.value {
            return
        }

        themePresetEffectPropertiesSubject.send(value)
    }

    func setQuickHideEnabled(_ value: Bool) {
        if value == quickHideEnabledSubject.value {
            return
        }

        quickHideEnabledSubject.send(value)
    }

    func setQuickHideTriggerKey(_ value: QuickHideTriggerKey) {
        if value == quickHideTriggerKeySubject.value {
            return
        }

        quickHideTriggerKeySubject.send(value)
    }

    func setAutomaticCheckForUpdatesEnabled(_ value: Bool) {
        if value == automaticCheckForUpdatesEnabledSubject.value {
            return
        }

        automaticCheckForUpdatesEnabledSubject.send(value)
    }

    func setAutomaticDownloadUpdatesEnabled(_ value: Bool) {
        if value == automaticDownloadUpdatesEnabledSubject.value {
            return
        }

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
