// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import AppKit
import Combine
@testable import Data
@testable import Domain
import Nimble
import XCTest

/// Tests the AeroSpace event-subscription path introduced for AeroSpace 0.21.0+.
///
/// The repository builds its own dependencies, so each test constructs a
/// repository with a specific reported AeroSpace version to select the mode
/// under test.
@MainActor
final class AeroSpaceRepositorySubscriptionTests: XCTestCase {
    /// A version that supports `aerospace subscribe`.
    private static let modernVersion = "0.21.3-Beta"

    /// A version predating `aerospace subscribe`.
    private static let legacyVersion = "0.20.3-Beta"

    /// Long enough for the 150ms refresh debounce to elapse.
    private static let debounceWait = Duration.milliseconds(400)

    private var mockConfigGateway: MockConfigurationGateway?
    private var mockCLIFactory: MockAeroSpaceCLIClientFactory?
    private var mockEventMonitor: MockAeroSpaceEventMonitor?
    private var repository: AeroSpaceRepository?

    override func tearDown() async throws {
        repository = nil
        mockConfigGateway = nil
        mockCLIFactory = nil
        mockEventMonitor = nil
    }

    /// Builds a repository reporting the given AeroSpace version.
    ///
    /// The legacy-callback cleanup flag is pre-set so that constructing a
    /// repository never touches an AeroSpace config file; the cleanup itself is
    /// covered by `testSubscriptionModeIssuesNoConfigReload`.
    /// - Parameter version: The AeroSpace version to report
    /// - Returns: The configured repository
    private func makeRepository(version: String) -> AeroSpaceRepository {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasRemovedLegacyAeroSpaceCallbacks.rawValue)

        let configGateway = MockConfigurationGateway()
        // The mock captures its emit-values at init, so drive the subjects instead.
        configGateway.emitCurrentAeroSpaceVersion(version)
        configGateway.setAeroSpacePath("/opt/homebrew/bin/aerospace")

        let cliFactory = MockAeroSpaceCLIClientFactory()
        // An empty JSON array decodes as both [Space] and [Window], so every
        // fetch in a refresh succeeds.
        cliFactory.mockClient.executeResult = .success(Data("[]".utf8))

        let eventMonitor = MockAeroSpaceEventMonitor()
        let runningAppChecker = MockRunningAppChecker()
        runningAppChecker.isRunningResult = true

        mockConfigGateway = configGateway
        mockCLIFactory = cliFactory
        mockEventMonitor = eventMonitor

        let repository = AeroSpaceRepository(
            iconCache: MockIconCache(),
            getAeroSpacePathUseCase: GetAeroSpacePathUseCase(configurationGateway: configGateway),
            getAeroSpaceConfigPathUseCase: GetAeroSpaceConfigPathUseCase(configurationGateway: configGateway),
            getOptimizedPerformanceEnabledUseCase:
            GetOptimizedPerformanceEnabledUseCase(configurationGateway: configGateway),
            getSpacesColorPropertiesUseCase: GetSpacesColorPropertiesUseCase(configurationGateway: configGateway),
            getAeroSpaceVersionUseCase: GetAeroSpaceVersionUseCase(configurationGateway: configGateway),
            eventMonitor: eventMonitor,
            cliFactory: cliFactory,
            commandExecutor: MockCommandExecutor(),
            runningAppChecker: runningAppChecker
        )
        self.repository = repository
        return repository
    }

    /// Waits long enough for a debounced refresh to run.
    private func waitForDebounce() async throws {
        try await Task.sleep(for: Self.debounceWait)
    }

    // MARK: - Mode Selection

    func testModernVersionStartsEventSubscription() async throws {
        // Given a repository running against AeroSpace 0.21.3
        _ = makeRepository(version: Self.modernVersion)
        try await waitForDebounce()

        guard let mockEventMonitor else {
            XCTFail("Dependencies not initialized")
            return
        }

        // Then the event monitor is started
        expect(mockEventMonitor.startCount) >= 1
    }

    func testSubscribesToEveryEventType() async throws {
        // Given a repository running against a modern AeroSpace
        _ = makeRepository(version: Self.modernVersion)
        try await waitForDebounce()

        guard let mockEventMonitor else {
            XCTFail("Dependencies not initialized")
            return
        }

        // Then it subscribes to every event type AeroSpace offers, so a newly
        // relevant event is never silently missed
        expect(Set(mockEventMonitor.subscribedEvents)) == Set(AeroSpaceEventType.allCases)
    }

    func testLegacyVersionDoesNotStartEventSubscription() async throws {
        // Given a repository running against AeroSpace 0.20.3
        _ = makeRepository(version: Self.legacyVersion)
        try await waitForDebounce()

        guard let mockEventMonitor else {
            XCTFail("Dependencies not initialized")
            return
        }

        // Then the event monitor is never started and the legacy path is used
        expect(mockEventMonitor.startCount) == 0
    }

    func testSubscriptionModeIssuesNoConfigReload() async throws {
        // Given a repository running against a modern AeroSpace
        _ = makeRepository(version: Self.modernVersion)
        try await waitForDebounce()

        guard let mockCLIFactory else {
            XCTFail("Dependencies not initialized")
            return
        }

        // Then it never rewrites and reloads the user's AeroSpace config, which
        // only the legacy callback path does
        expect(mockCLIFactory.mockClient.callCount(of: "reload-config")) == 0
    }

    // MARK: - Event Handling

    func testRefreshableEventTriggersRefresh() async throws {
        // Given a running subscription
        _ = makeRepository(version: Self.modernVersion)
        try await waitForDebounce()

        guard let mockEventMonitor, let mockCLIFactory else {
            XCTFail("Dependencies not initialized")
            return
        }

        let before = mockCLIFactory.mockClient.callCount(of: "list-workspaces")

        // When a focus change arrives
        mockEventMonitor.emit(.event(.focusChanged(windowId: 42, workspace: "1")))
        try await waitForDebounce()

        // Then spaces are refetched
        expect(mockCLIFactory.mockClient.callCount(of: "list-workspaces")) > before
    }

    func testInputOnlyEventDoesNotTriggerRefresh() async throws {
        // Given a running subscription
        _ = makeRepository(version: Self.modernVersion)
        try await waitForDebounce()

        guard let mockEventMonitor, let mockCLIFactory else {
            XCTFail("Dependencies not initialized")
            return
        }

        let before = mockCLIFactory.mockClient.callCount(of: "list-workspaces")

        // When only binding and mode events arrive, which cannot change the
        // spaces model
        mockEventMonitor.emit(.event(.bindingTriggered(mode: "main", binding: "alt-1")))
        mockEventMonitor.emit(.event(.modeChanged(mode: "main")))
        try await waitForDebounce()

        // Then no refetch happens
        expect(mockCLIFactory.mockClient.callCount(of: "list-workspaces")) == before
    }

    func testEventBurstIsCoalescedIntoOneRefresh() async throws {
        // Given a running subscription
        _ = makeRepository(version: Self.modernVersion)
        try await waitForDebounce()

        guard let mockEventMonitor, let mockCLIFactory else {
            XCTFail("Dependencies not initialized")
            return
        }

        let before = mockCLIFactory.mockClient.callCount(of: "list-workspaces")

        // When AeroSpace emits the burst a single workspace switch produces
        mockEventMonitor.emit(.event(.focusedWorkspaceChanged(workspace: "2", previousWorkspace: "1")))
        mockEventMonitor.emit(.event(.focusChanged(windowId: 7, workspace: "2")))
        mockEventMonitor.emit(.event(.focusedMonitorChanged(workspace: "2", monitorId: 1)))
        try await waitForDebounce()

        // Then the debounce collapses them into one refresh, which issues
        // list-workspaces twice (all workspaces, then the focused one)
        let refreshCalls = mockCLIFactory.mockClient.callCount(of: "list-workspaces") - before
        expect(refreshCalls) == 2
    }

    // MARK: - Connection State

    func testDisconnectMarksAeroSpaceAsNotRunning() async throws {
        // Given a connected subscription
        let repository = makeRepository(version: Self.modernVersion)
        try await waitForDebounce()

        guard let mockEventMonitor else {
            XCTFail("Dependencies not initialized")
            return
        }

        mockEventMonitor.emit(.connected)
        try await waitForDebounce()

        var states: [Bool] = []
        let cancellable = repository.aeroSpaceRunningPublisher.sink { states.append($0) }
        defer { cancellable.cancel() }

        // When the connection drops, as it does when AeroSpace quits
        mockEventMonitor.emit(.disconnected)
        try await waitForDebounce()

        // Then the app reports AeroSpace as not running
        expect(states.last) == false
    }
}
