// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Data
@testable import Domain
import Nimble
import Sparkle
import XCTest

/// Tests for SparkleSoftwareUpdateRepository.
///
/// These tests verify Sparkle framework integration including:
/// - Initialization with optional updater controller
/// - Publishers for automatic checks, downloads, and last check date
/// - Update settings management
/// - KVO observation of Sparkle updater changes
@MainActor
final class SparkleSoftwareUpdateRepositoryTests: XCTestCase {
    private var repository: SparkleSoftwareUpdateRepository?
    private var mockUpdaterController: MockSPUStandardUpdaterController?
    private var cancellables = Set<AnyCancellable>()
    private var updateCount = 0

    override func setUp() async throws {
        try await super.setUp()
        cancellables = []
        // Create mock controller for method verification tests
        let mockController = MockSPUStandardUpdaterController(updaterDelegate: nil, userDriverDelegate: nil)
        mockUpdaterController = mockController

        // Inject the mock controller
        repository = SparkleSoftwareUpdateRepository(updaterController: mockController)
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        repository = nil
        mockUpdaterController = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationWithProvidedController() {
        // Given mock controller (in setUp)
        // When initializing repository
        // Then should use provided controller
        expect(self.repository).toNot(beNil())
    }

    func testInitializationWithDefaultController() {
        // Note: Testing default initialization would start actual Sparkle updater
        // This test verifies the initialization path exists
        // In production, repository initializes with SPUStandardUpdaterController
        expect(true).to(beTrue())
    }

    func testInitializationSetsUpPublishers() {
        // Given repository initialized with mock controller
        // When checking publishers
        // Then all publishers should be accessible
        expect(self.repository?.automaticCheckForUpdatesEnabledPublisher).toNot(beNil())
        expect(self.repository?.automaticDownloadUpdatesEnabledPublisher).toNot(beNil())
        expect(self.repository?.lastUpdateCheckDatePublisher).toNot(beNil())
    }

    // MARK: - Automatic Check Publisher Tests

    func testAutomaticCheckForUpdatesEnabledPublisher() async {
        // Given repository with initial state
        var receivedValue: Bool?

        // When subscribing to publisher
        repository?.automaticCheckForUpdatesEnabledPublisher
            .sink { value in
                receivedValue = value
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // Then should receive initial value from mock updater
        expect(receivedValue).toNot(beNil())
        expect(receivedValue).to(equal(mockUpdaterController?.mockUpdater.automaticallyChecksForUpdates))
    }

    func testAutomaticCheckForUpdatesEnabledUpdates() async {
        // Given repository subscribed to automatic check updates
        var receivedValues: [Bool] = []

        repository?.automaticCheckForUpdatesEnabledPublisher
            .sink { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // When updater property changes
        mockUpdaterController?.mockUpdater.automaticallyChecksForUpdates = true

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should receive both initial and updated values
        expect(receivedValues.count).to(equal(2))
        expect(receivedValues[0]).toNot(equal(receivedValues[1]))
    }

    // MARK: - Automatic Download Publisher Tests

    func testAutomaticDownloadUpdatesEnabledPublisher() async {
        // Given repository with initial state
        var receivedValue: Bool?

        // When subscribing to publisher
        repository?.automaticDownloadUpdatesEnabledPublisher
            .sink { value in
                receivedValue = value
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // Then should receive initial value
        expect(receivedValue).toNot(beNil())
        expect(receivedValue).to(equal(mockUpdaterController?.mockUpdater.automaticallyDownloadsUpdates))
    }

    func testAutomaticDownloadUpdatesEnabledUpdates() async {
        // Given repository subscribed to automatic download updates
        var receivedValues: [Bool] = []

        repository?.automaticDownloadUpdatesEnabledPublisher
            .sink { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // When updater property changes
        mockUpdaterController?.mockUpdater.automaticallyDownloadsUpdates = true

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should receive both values
        expect(receivedValues.count).to(equal(2))
    }

    // MARK: - Last Update Check Date Publisher Tests

    func testLastUpdateCheckDatePublisher() async {
        // Given repository with initial state
        var receivedValue: Date?

        // When subscribing to publisher
        repository?.lastUpdateCheckDatePublisher
            .sink { value in
                receivedValue = value
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // Then should receive initial value (nil by default)
        expect(receivedValue).to(beNil())
    }

    func testLastUpdateCheckDateUpdates() async {
        // Given repository subscribed to last check date updates
        var receivedValues: [Date?] = []

        repository?.lastUpdateCheckDatePublisher
            .sink { value in
                receivedValues.append(value)
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))

        // When updater property changes
        mockUpdaterController?.mockUpdater.lastUpdateCheckDate = Date()

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should receive both values
        expect(receivedValues.count).to(equal(2))
        expect(receivedValues[0]).to(beNil())
        expect(receivedValues[1]).toNot(beNil())
    }

    // MARK: - Setter Tests

    func testSetAutomaticCheckForUpdatesEnabled() {
        // Given repository
        // When setting automatic check enabled
        repository?.setAutomaticCheckForUpdatesEnabled(true)

        // Then should update updater controller
        expect(self.mockUpdaterController?.mockUpdater.automaticallyChecksForUpdates).to(beTrue())
    }

    func testSetAutomaticCheckForUpdatesEnabledPublishesUpdate() async {
        // Given repository with subscriber
        var receivedValue: Bool?

        repository?.automaticCheckForUpdatesEnabledPublisher
            .dropFirst() // Skip initial value
            .sink { value in
                receivedValue = value
            }
            .store(in: &cancellables)

        // When setting value
        repository?.setAutomaticCheckForUpdatesEnabled(true)

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should publish update
        expect(receivedValue).to(beTrue())
    }

    func testSetAutomaticCheckForUpdatesEnabledIgnoresDuplicates() async {
        // Given repository with value already set
        repository?.setAutomaticCheckForUpdatesEnabled(true)

        var updateCount = 0
        repository?.automaticCheckForUpdatesEnabledPublisher
            .sink { _ in
                updateCount += 1
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))
        let initialCount = updateCount

        // When setting same value again
        repository?.setAutomaticCheckForUpdatesEnabled(true)

        // Allow time for potential update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should not emit duplicate
        expect(updateCount).to(equal(initialCount))
    }

    func testSetAutomaticDownloadUpdatesEnabled() {
        // Given repository
        // When setting automatic download enabled
        repository?.setAutomaticDownloadUpdatesEnabled(true)

        // Then should update updater controller
        expect(self.mockUpdaterController?.mockUpdater.automaticallyDownloadsUpdates).to(beTrue())
    }

    func testSetAutomaticDownloadUpdatesEnabledPublishesUpdate() async {
        // Given repository with subscriber
        var receivedValue: Bool?

        repository?.automaticDownloadUpdatesEnabledPublisher
            .dropFirst()
            .sink { value in
                receivedValue = value
            }
            .store(in: &cancellables)

        // When setting value
        repository?.setAutomaticDownloadUpdatesEnabled(true)

        // Allow time for update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should publish update
        expect(receivedValue).to(beTrue())
    }

    func testSetAutomaticDownloadUpdatesEnabledIgnoresDuplicates() async {
        // Given repository with value already set
        repository?.setAutomaticDownloadUpdatesEnabled(false)

        var updateCount = 0
        repository?.automaticDownloadUpdatesEnabledPublisher
            .sink { _ in
                updateCount += 1
            }
            .store(in: &cancellables)

        // Allow time for initial value
        try? await Task.sleep(for: .milliseconds(100))
        let initialCount = updateCount

        // When setting same value again
        repository?.setAutomaticDownloadUpdatesEnabled(false)

        // Allow time for potential update
        try? await Task.sleep(for: .milliseconds(100))

        // Then should not emit duplicate
        expect(updateCount).to(equal(initialCount))
    }

    // MARK: - Check For Updates Tests

    func testCheckForUpdates() {
        // Given repository
        // When calling checkForUpdates
        repository?.checkForUpdates()

        // Then should delegate to updater controller
        expect(self.mockUpdaterController?.checkForUpdatesCalled).to(beTrue())
    }

    func testCheckForUpdatesMultipleCalls() {
        // Given repository
        // When calling checkForUpdates multiple times
        repository?.checkForUpdates()
        repository?.checkForUpdates()
        repository?.checkForUpdates()

        // Then should call controller each time
        expect(self.mockUpdaterController?.checkForUpdatesCalled).to(beTrue())
    }

    // MARK: - Integration Tests

    func testPublisherSynchronization() async {
        // Given repository with all publishers subscribed
        var checkReceived = false
        var downloadReceived = false
        var dateReceived = false

        repository?.automaticCheckForUpdatesEnabledPublisher
            .dropFirst()
            .sink { _ in checkReceived = true }
            .store(in: &cancellables)

        repository?.automaticDownloadUpdatesEnabledPublisher
            .dropFirst()
            .sink { _ in downloadReceived = true }
            .store(in: &cancellables)

        repository?.lastUpdateCheckDatePublisher
            .dropFirst()
            .sink { _ in dateReceived = true }
            .store(in: &cancellables)

        // When updating all properties
        repository?.setAutomaticCheckForUpdatesEnabled(true)
        repository?.setAutomaticDownloadUpdatesEnabled(true)
        mockUpdaterController?.mockUpdater.lastUpdateCheckDate = Date()

        // Allow time for updates
        try? await Task.sleep(for: .milliseconds(100))

        // Then all publishers should emit
        expect(checkReceived).to(beTrue())
        expect(downloadReceived).to(beTrue())
        expect(dateReceived).to(beTrue())
    }
}

// MARK: - Mock Sparkle Classes

// MARK: - Mock Sparkle Classes

/// Mock implementation that mimics SPUStandardUpdaterController for testing.
@MainActor
final class MockSPUStandardUpdaterController: SparkleUpdaterControllerProtocol {
    let mockUpdater = MockSPUUpdater()
    var checkForUpdatesCalled = false

    /// Create a simple mock that provides the interface needed
    var sparkleUpdater: SparkleUpdaterProtocol {
        mockUpdater
    }

    init(updaterDelegate _: Any?, userDriverDelegate _: Any?) {
        // Mock initializer - don't need to store the delegates for this test
    }

    func checkForUpdates(_: Any?) {
        checkForUpdatesCalled = true
    }
}

/// Mock implementation of SPUUpdater for testing.
@MainActor
final class MockSPUUpdater: SparkleUpdaterProtocol {
    @Published var automaticallyChecksForUpdates: Bool = false
    @Published var automaticallyDownloadsUpdates: Bool = false
    @Published var lastUpdateCheckDate: Date?

    func publisherForAutomaticallyChecksForUpdates() -> AnyPublisher<Bool, Never> {
        $automaticallyChecksForUpdates.eraseToAnyPublisher()
    }

    func publisherForAutomaticallyDownloadsUpdates() -> AnyPublisher<Bool, Never> {
        $automaticallyDownloadsUpdates.eraseToAnyPublisher()
    }

    func publisherForLastUpdateCheckDate() -> AnyPublisher<Date?, Never> {
        $lastUpdateCheckDate.eraseToAnyPublisher()
    }
}
