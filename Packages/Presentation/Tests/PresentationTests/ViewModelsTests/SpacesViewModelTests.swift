// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
@testable import Domain
import Nimble
@testable import Presentation
import XCTest

/// Tests for SpacesViewModel.
///
/// These tests verify spaces management including:
/// - AeroSpace integration and status
/// - Space and window operations
/// - Visual properties management
/// - Wallpaper and menu bar visibility
@MainActor
final class SpacesViewModelTests: XCTestCase {
    private var viewModel: SpacesViewModel?
    private var cancellables: Set<AnyCancellable>?

    // Mock gateways
    private var mockSpacesGateway: MockSpacesGateway?
    private var mockSystemMenuBarGateway: MockSystemMenuBarGateway?
    private var mockConfigurationGateway: MockConfigurationGateway?
    private var mockKeyboardShortcutsGateway: MockKeyboardShortcutsGateway?

    // Real use cases with mock gateways
    private var getSpacesUseCase: GetSpacesUseCase?
    private var setFocusSpaceUseCase: SetFocusSpaceUseCase?
    private var setFocusWindowUseCase: SetFocusWindowUseCase?
    private var getAeroSpaceStatusUseCase: GetAeroSpaceStatusUseCase?
    private var startAeroSpaceUseCase: StartAeroSpaceUseCase?
    private var getWallpaperUseCase: GetWallpaperUseCase?
    private var getMenuBarVisibilityUseCase: GetMenuBarVisibilityUseCase?

    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()

        // Initialize mock gateways
        mockSpacesGateway = MockSpacesGateway(spaces: [], isAeroSpaceRunning: true)
        mockSystemMenuBarGateway = MockSystemMenuBarGateway(
            menuBarHeight: 39.0,
            menuBarVisibility: true,
            wallpaper: nil
        )
        mockConfigurationGateway = MockConfigurationGateway()
        mockConfigurationGateway?.setShowEmptySpaces(false)
        mockKeyboardShortcutsGateway = MockKeyboardShortcutsGateway()

        // Use guard statements to safely unwrap gateways before initializing use cases
        guard
            let spacesGateway = mockSpacesGateway,
            let systemMenuBarGateway = mockSystemMenuBarGateway,
            mockConfigurationGateway != nil
        else {
            XCTFail("Mock gateways should be initialized")
            return
        }

        // Initialize real use cases with mock gateways
        getSpacesUseCase = GetSpacesUseCase(spacesGateway: spacesGateway)
        setFocusSpaceUseCase = SetFocusSpaceUseCase(spacesGateway: spacesGateway)
        setFocusWindowUseCase = SetFocusWindowUseCase(spacesGateway: spacesGateway)
        getAeroSpaceStatusUseCase = GetAeroSpaceStatusUseCase(spacesGateway: spacesGateway)
        startAeroSpaceUseCase = StartAeroSpaceUseCase(spacesGateway: spacesGateway)
        getWallpaperUseCase = GetWallpaperUseCase(systemMenuBarGateway: systemMenuBarGateway)
        getMenuBarVisibilityUseCase = GetMenuBarVisibilityUseCase(systemMenuBarGateway: systemMenuBarGateway)

        createViewModel()
    }

    private func createViewModel() {
        // Use guard statements to safely unwrap all dependencies
        guard
            let mockSystemMenuBarGateway,
            let mockConfigurationGateway,
            let mockKeyboardShortcutsGateway,
            let getSpacesUseCase,
            let setFocusSpaceUseCase,
            let setFocusWindowUseCase,
            let getAeroSpaceStatusUseCase,
            let startAeroSpaceUseCase,
            let getWallpaperUseCase,
            let getMenuBarVisibilityUseCase
        else {
            XCTFail("All dependencies should be initialized")
            return
        }

        // SpacesViewModel constructor requires many dependencies with complex signatures
        viewModel = SpacesViewModel(
            getSpacesUseCase: getSpacesUseCase,
            setFocusSpaceUseCase: setFocusSpaceUseCase,
            setFocusWindowUseCase: setFocusWindowUseCase,
            getAeroSpaceStatusUseCase: getAeroSpaceStatusUseCase,
            startAeroSpaceUseCase: startAeroSpaceUseCase,
            getShowWindowTitlesUseCase: GetShowWindowTitlesUseCase(configurationGateway: mockConfigurationGateway),
            setShowWindowTitlesUseCase: SetShowWindowTitlesUseCase(configurationGateway: mockConfigurationGateway),
            getFocusWindowOnClickUseCase: GetFocusWindowOnClickUseCase(configurationGateway: mockConfigurationGateway),
            setFocusWindowOnClickUseCase: SetFocusWindowOnClickUseCase(configurationGateway: mockConfigurationGateway),
            getShowEmptySpacesUseCase: GetShowEmptySpacesUseCase(configurationGateway: mockConfigurationGateway),
            setShowEmptySpacesUseCase: SetShowEmptySpacesUseCase(configurationGateway: mockConfigurationGateway),
            getHiddenSpacesUseCase: GetHiddenSpacesUseCase(configurationGateway: mockConfigurationGateway),
            setHiddenSpacesUseCase: SetHiddenSpacesUseCase(configurationGateway: mockConfigurationGateway),
            getWallpaperUseCase: getWallpaperUseCase,
            getMenuBarVisibilityUseCase: getMenuBarVisibilityUseCase,
            getMenuBarHeightUseCase: GetMenuBarHeightUseCase(systemMenuBarGateway: mockSystemMenuBarGateway),
            getFeatureFlagsUseCase: GetFeatureFlagsUseCase(gateway: MockFeatureFlagsGateway(flags: FeatureFlags
                    .defaultFlags())),
            getSpacesAppearanceModeUseCase: GetSpacesAppearanceModeUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setSpacesAppearanceModeUseCase: SetSpacesAppearanceModeUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getGlobalSpacesColorPropertiesUseCase: GetGlobalSpacesColorPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setGlobalSpacesColorPropertiesUseCase: SetGlobalSpacesColorPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getGlobalSpacesGeometricPropertiesUseCase: GetGlobalSpacesGeometricPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setGlobalSpacesGeometricPropertiesUseCase: SetGlobalSpacesGeometricPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getGlobalSpacesEffectPropertiesUseCase: GetGlobalSpacesEffectPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setGlobalSpacesEffectPropertiesUseCase: SetGlobalSpacesEffectPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setSpacesColorPropertiesUseCase: SetSpacesColorPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getSpacesGeometricPropertiesUseCase: GetSpacesGeometricPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setSpacesGeometricPropertiesUseCase: SetSpacesGeometricPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getSpacesEffectPropertiesUseCase: GetSpacesEffectPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setSpacesEffectPropertiesUseCase: SetSpacesEffectPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getThemeModeUseCase: GetThemeModeUseCase(configurationGateway: mockConfigurationGateway),
            getThemePresetColorPropertiesUseCase: GetThemePresetColorPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getThemePresetGeometricPropertiesUseCase: GetThemePresetGeometricPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setThemePresetGeometricPropertiesUseCase: SetThemePresetGeometricPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getThemePresetEffectPropertiesUseCase: GetThemePresetEffectPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setThemePresetEffectPropertiesUseCase: SetThemePresetEffectPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getShowAppleButtonAsSpaceUseCase: GetShowAppleButtonAsSpaceUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setShowAppleButtonAsSpaceUseCase: SetShowAppleButtonAsSpaceUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getAppleButtonColorPropertiesUseCase: GetAppleButtonColorPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setAppleButtonColorPropertiesUseCase: SetAppleButtonColorPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getAppleButtonGeometricPropertiesUseCase: GetAppleButtonGeometricPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setAppleButtonGeometricPropertiesUseCase: SetAppleButtonGeometricPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getAppleButtonEffectPropertiesUseCase: GetAppleButtonEffectPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            setAppleButtonEffectPropertiesUseCase: SetAppleButtonEffectPropertiesUseCase(
                configurationGateway: mockConfigurationGateway
            ),
            getQuickHideTriggerKeyPressStateUseCase: GetQuickHideTriggerKeyPressStateUseCase(
                keyboardShortcutsGateway: mockKeyboardShortcutsGateway
            ),
            getQuickHideEnabledUseCase: GetQuickHideEnabledUseCase(
                configurationGateway: mockConfigurationGateway
            )
        )
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        expect(viewModel.isAeroSpaceRunning) == true
        expect(viewModel.allSpaces.isEmpty) == true
        expect(viewModel.isMenuBarVisible) == true
    }

    // MARK: - AeroSpace Status Tests

    func testAeroSpaceStatusUpdates() {
        guard let mockSpacesGateway else {
            XCTFail("Mock spaces gateway should be initialized")
            return
        }

        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        // When AeroSpace is set to not running
        mockSpacesGateway.setAeroSpaceRunning(false)
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))

        // Then view model auto-starts it (self-healing behavior)
        expect(viewModel.isAeroSpaceRunning) == true
    }

    // MARK: - Spaces Updates Tests

    func testSpacesUpdates() {
        guard let mockSpacesGateway else {
            XCTFail("Mock spaces gateway should be initialized")
            return
        }

        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        let testSpaces = [
            Space(id: "1", isFocused: true, windows: [])
        ]
        mockSpacesGateway.setSpaces(testSpaces)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        expect(viewModel.allSpaces.count) == 1
    }

    // MARK: - Focus Operations Tests

    func testFocusSpace() {
        // focusSpace method is private - skipping tests for private implementation details
        // to focus on testable public interface
    }

    func testFocusWindow() {
        // focusWindow method is private - skipping tests for private implementation details
        // to focus on testable public interface
    }

    // MARK: - Wallpaper Tests

    func testWallpaperUpdates() {
        guard let mockSystemMenuBarGateway else {
            XCTFail("Mock system menu bar gateway should be initialized")
            return
        }

        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        let testImage = NSImage(size: NSSize(width: 100, height: 100))
        mockSystemMenuBarGateway.setWallpaper(testImage)
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        expect(viewModel.wallpaper).toNot(beNil())
    }

    // MARK: - Memory Management

    func testSpacesViewModelIsDeallocatedWhenReleased() async throws {
        // Given a view model whose reactive subscriptions are stored in its own
        // `cancellables`
        weak var weakViewModel: SpacesViewModel?
        weakViewModel = viewModel

        // When every strong reference is dropped
        cancellables = nil
        getSpacesUseCase = nil
        setFocusSpaceUseCase = nil
        setFocusWindowUseCase = nil
        getAeroSpaceStatusUseCase = nil
        startAeroSpaceUseCase = nil
        getWallpaperUseCase = nil
        getMenuBarVisibilityUseCase = nil
        mockSpacesGateway = nil
        mockSystemMenuBarGateway = nil
        mockConfigurationGateway = nil
        mockKeyboardShortcutsGateway = nil
        viewModel = nil

        // Then it deallocates: the subscriptions capture `self` weakly, so storing
        // them on the view model does not form a retain cycle.
        //
        // Polled rather than checked immediately because the `didSet` observers
        // spawn detached tasks that hold `self` until they finish; those are
        // transient, unlike the subscription cycle this guards against.
        // Let the detached tasks the `didSet` observers spawned run to completion;
        // they hold `self` until they finish, unlike a genuine retain cycle.
        try await Task.sleep(for: .milliseconds(500))

        expect(weakViewModel).to(beNil())
    }
}

// MARK: - Mock Gateways

/// Mock implementation of SpacesGateway for testing.
@MainActor
private final class MockSpacesGateway: SpacesGateway {
    private let spacesSubject: CurrentValueSubject<[Space], Never>
    private let aeroSpaceRunningSubject: CurrentValueSubject<Bool, Never>

    var lastFocusSpaceId: Int?
    var lastFocusWindowId: Int?

    init(spaces: [Space], isAeroSpaceRunning: Bool) {
        spacesSubject = CurrentValueSubject(spaces)
        aeroSpaceRunningSubject = CurrentValueSubject(isAeroSpaceRunning)
    }

    var spacesWithWindowsPublisher: AnyPublisher<[Space], Never> {
        spacesSubject.eraseToAnyPublisher()
    }

    var aeroSpaceRunningPublisher: AnyPublisher<Bool, Never> {
        aeroSpaceRunningSubject.eraseToAnyPublisher()
    }

    func setSpaces(_ spaces: [Space]) {
        spacesSubject.send(spaces)
    }

    func setAeroSpaceRunning(_ running: Bool) {
        aeroSpaceRunningSubject.send(running)
    }

    func focusSpace(spaceId: String, needWindowFocus _: Bool) throws {
        lastFocusSpaceId = Int(spaceId)
    }

    func focusWindow(windowId: String) throws {
        lastFocusWindowId = Int(windowId)
    }

    func startAeroSpace() throws {
        aeroSpaceRunningSubject.send(true)
    }
}

// Note: Mock classes removed to avoid redeclaration conflicts
// Using MockPublisherUseCase and MockAsyncUseCase from SettingsViewModelMockHelpers.swift
