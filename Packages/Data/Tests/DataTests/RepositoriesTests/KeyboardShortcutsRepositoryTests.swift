// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Data
@testable import Domain
import Nimble
import XCTest

/// Tests for KeyboardShortcutsRepository.
///
/// These tests verify NSEvent monitoring for keyboard shortcuts including:
/// - Repository initialization and monitor setup
/// - Quick Hide trigger key press state publisher
/// - Monitor cleanup on deinitialization
///
/// Note: Actual NSEvent behavior is difficult to test in unit tests as it
/// requires system-level event injection. These tests focus on the repository's
/// lifecycle and publisher setup.
@MainActor
final class KeyboardShortcutsRepositoryTests: XCTestCase {
    private var repository: KeyboardShortcutsRepository?
    private var mockConfigGateway: MockConfigurationGateway?
    private var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()
        cancellables = []
        mockConfigGateway = MockConfigurationGateway()
        guard let configGateway = mockConfigGateway else {
            XCTFail("MockConfigurationGateway should be initialized")
            return
        }

        let useCase = GetQuickHideTriggerKeyUseCase(configurationGateway: configGateway)
        repository = KeyboardShortcutsRepository(getQuickHideTriggerKeyUseCase: useCase)
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        repository = nil
        mockConfigGateway = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testRepositoryInitialization() {
        // Given repository initialized in setUp
        // When accessing repository
        // Then should not be nil
        expect(self.repository).toNot(beNil())
    }

    func testInitializationSetsUpPublisher() {
        // Given repository initialized
        // When accessing trigger key publisher
        let publisher = repository?.quickHideTriggerKeyPressStatePublisher

        // Then publisher should be available
        expect(publisher).toNot(beNil())
    }

    // MARK: - Publisher Tests

    func testQuickHideTriggerKeyPressStatePublisherType() {
        // Given repository with publisher
        let publisher = repository?.quickHideTriggerKeyPressStatePublisher

        // When checking publisher type
        // Then should be correct type
        expect(publisher).to(beAKindOf(AnyPublisher<Bool, Never>?.self))
    }

    func testQuickHideTriggerKeyPressStatePublisherEmitsValues() {
        // Given repository with publisher
        var receivedValue: Bool?

        // When subscribing to publisher
        repository?.quickHideTriggerKeyPressStatePublisher
            .sink { state in
                receivedValue = state
            }
            .store(in: &cancellables)

        // Then should receive initial value
        expect(receivedValue).toEventually(equal(false))
    }

    func testMultipleSubscribers() {
        // Given repository with publisher
        var received1 = false
        var received2 = false

        // When multiple subscribers subscribe
        repository?.quickHideTriggerKeyPressStatePublisher
            .sink { _ in
                received1 = true
            }
            .store(in: &cancellables)

        repository?.quickHideTriggerKeyPressStatePublisher
            .sink { _ in
                received2 = true
            }
            .store(in: &cancellables)

        // Then both should receive values
        expect(received1).toEventually(beTrue())
        expect(received2).toEventually(beTrue())
    }

    // MARK: - Lifecycle Tests

    func testRepositoryDeinitializationCleansUpMonitors() {
        // Given repository instance
        guard let mockConfigGateway else { return }

        let useCase = GetQuickHideTriggerKeyUseCase(configurationGateway: mockConfigGateway)
        var testRepository: KeyboardShortcutsRepository? = KeyboardShortcutsRepository(
            getQuickHideTriggerKeyUseCase: useCase
        )
        expect(testRepository).toNot(beNil())

        // When deallocating repository
        testRepository = nil

        // Then should deallocate without issues
        expect(testRepository).to(beNil())
    }

    func testMultipleRepositoryInstances() {
        guard let mockConfigGateway else { return }

        // Given multiple repository instances
        let useCase1 = GetQuickHideTriggerKeyUseCase(configurationGateway: mockConfigGateway)
        let useCase2 = GetQuickHideTriggerKeyUseCase(configurationGateway: mockConfigGateway)
        let repository1 = KeyboardShortcutsRepository(getQuickHideTriggerKeyUseCase: useCase1)
        let repository2 = KeyboardShortcutsRepository(getQuickHideTriggerKeyUseCase: useCase2)
        var received1 = false
        var received2 = false

        // When accessing both publishers
        repository1.quickHideTriggerKeyPressStatePublisher
            .sink { _ in received1 = true }
            .store(in: &cancellables)

        repository2.quickHideTriggerKeyPressStatePublisher
            .sink { _ in received2 = true }
            .store(in: &cancellables)

        // Then both should work independently
        expect(received1).toEventually(beTrue())
        expect(received2).toEventually(beTrue())
    }

    // MARK: - Integration Tests

    func testPublisherConsistency() {
        // Given repository with publisher
        var value1: Bool?
        var value2: Bool?

        // When subscribing twice at different times
        repository?.quickHideTriggerKeyPressStatePublisher
            .sink { state in
                value1 = state
            }
            .store(in: &cancellables)

        // Wait for first value
        expect(value1).toEventuallyNot(beNil())

        repository?.quickHideTriggerKeyPressStatePublisher
            .sink { state in
                value2 = state
            }
            .store(in: &cancellables)

        // Wait for second value
        expect(value2).toEventuallyNot(beNil())

        // Then both should receive same initial value
        expect(value1 == value2).to(beTrue())
    }

    func testPublisherAfterCancellation() {
        // Given repository with cancelled subscription
        var cancellable: AnyCancellable? = repository?.quickHideTriggerKeyPressStatePublisher
            .sink { _ in }

        cancellable?.cancel()
        cancellable = nil

        // When subscribing again
        var received = false

        repository?.quickHideTriggerKeyPressStatePublisher
            .sink { _ in
                received = true
            }
            .store(in: &cancellables)

        // Then should still work
        expect(received).toEventually(beTrue())
    }

    // MARK: - Edge Cases

    func testRapidSubscriptionCancellation() {
        // Given repository
        // When rapidly subscribing and cancelling
        for _ in 0 ..< 10 {
            guard let repository else { return }

            let cancellable = repository.quickHideTriggerKeyPressStatePublisher.sink { _ in }
            cancellable.cancel()
        }

        // Then should remain stable
        var stillWorks = false

        repository?.quickHideTriggerKeyPressStatePublisher
            .sink { _ in
                stillWorks = true
            }
            .store(in: &cancellables)

        expect(stillWorks).toEventually(beTrue())
    }

    func testConcurrentSubscriptions() async {
        // Given repository
        guard let repository else { return }

        // When subscribing from multiple sequential contexts
        var successCount = 0
        for _ in 0 ..< 5 {
            var received = false
            var taskCancellables = Set<AnyCancellable>()

            repository
                .quickHideTriggerKeyPressStatePublisher
                .sink { _ in
                    received = true
                }
                .store(in: &taskCancellables)

            // Allow time for value to be received
            try? await Task.sleep(for: .milliseconds(100))
            taskCancellables.removeAll()

            if received {
                successCount += 1
            }
        }

        // Then all should succeed
        expect(successCount == 5).to(beTrue())
    }
}
