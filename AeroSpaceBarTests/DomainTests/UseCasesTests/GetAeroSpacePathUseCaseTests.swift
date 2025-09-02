// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

@testable import AeroSpaceBar
import Combine
import XCTest

final class GetAeroSpacePathUseCaseTests: XCTestCase {
    var useCase: GetAeroSpacePathUseCase?
    private var mockConfigurationGateway: MockConfigurationGateway?
    var cancellables: Set<AnyCancellable>?

    func setUp() {
        // TODO: Initialize with proper actor context
        // mockConfigurationGateway = MockConfigurationGateway()
        // useCase = GetAeroSpacePathUseCase(configurationGateway: mockConfigurationGateway)
        cancellables = Set<AnyCancellable>()
    }

    func tearDown() {
        cancellables?.removeAll()
        useCase = nil
        mockConfigurationGateway = nil
    }

    func testGetAeroSpacePathUseCaseInitialization() {
        // TODO: Test use case initialization
    }

    func testExecute() {
        // TODO: Test execute method
    }

    func testExecuteReturnsPublisher() {
        // TODO: Test execute returns publisher
    }
}

// MARK: - Mock Configuration Gateway

private class MockConfigurationGateway: ConfigurationGateway {
    var showWindowTitlesPublisher: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()
    var aeroSpacePathPublisher: AnyPublisher<String, Never> = Just("").eraseToAnyPublisher()
    var launchAtLoginPublisher: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()
    var transparencyPublisher: AnyPublisher<Double, Never> = Just(0.9).eraseToAnyPublisher()
    var focusWindowOnClickPublisher: AnyPublisher<Bool, Never> = Just(true).eraseToAnyPublisher()
    var enablePerformanceMetricsPublisher: AnyPublisher<Bool, Never> = Just(true).eraseToAnyPublisher()
    var logLevelPublisher: AnyPublisher<Logger.Level, Never> = Just(.info).eraseToAnyPublisher()
    var currentAeroSpaceVersionPublisher: AnyPublisher<String?, Never> = Just(nil).eraseToAnyPublisher()
    var menuBarHeightPublisher: AnyPublisher<CGFloat, Never> = Just(26).eraseToAnyPublisher()
    var menuBarVerticalPaddingPublisher: AnyPublisher<CGFloat, Never> = Just(6).eraseToAnyPublisher()
    var menuBarHorizontalPaddingPublisher: AnyPublisher<CGFloat, Never> = Just(54).eraseToAnyPublisher()
    var widgetSpacingPublisher: AnyPublisher<CGFloat, Never> = Just(8).eraseToAnyPublisher()
    var animationDurationPublisher: AnyPublisher<Double, Never> = Just(0.2).eraseToAnyPublisher()
    var windowIconSizePublisher: AnyPublisher<CGFloat, Never> = Just(20).eraseToAnyPublisher()
    var spaceCornerRadiusPublisher: AnyPublisher<CGFloat, Never> = Just(20).eraseToAnyPublisher()
    var windowCornerRadiusPublisher: AnyPublisher<CGFloat, Never> = Just(8).eraseToAnyPublisher()

    func setShowWindowTitles(_: Bool) async { }
    func setAeroSpacePath(_: String) async { }
    func setLaunchAtLogin(_: Bool) async { }
    func setTransparency(_: Double) async { }
    func setFocusWindowOnClick(_: Bool) async { }
    func setEnablePerformanceMetrics(_: Bool) async { }
    func setLogLevel(_: Logger.Level) async { }
    func setMenuBarHeight(_: CGFloat) async { }
    func setMenuBarVerticalPadding(_: CGFloat) async { }
    func setMenuBarHorizontalPadding(_: CGFloat) async { }
    func setWidgetSpacing(_: CGFloat) async { }
    func setAnimationDuration(_: Double) async { }
    func setWindowIconSize(_: CGFloat) async { }
    func setSpaceCornerRadius(_: CGFloat) async { }
    func setWindowCornerRadius(_: CGFloat) async { }
    func openAeroSpaceConfig() async { }
    func resetToDefaults() async { }
}
