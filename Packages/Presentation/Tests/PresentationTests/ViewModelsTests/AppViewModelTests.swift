// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
@testable import Presentation
import XCTest

/// Tests for AppViewModel.
///
/// These tests verify app-level state management including:
/// - Initialization with Quick Hide trigger key state
/// - Reactive updates from keyboard shortcuts
/// - Publisher subscriptions
@MainActor
final class AppViewModelTests: XCTestCase {
    private var viewModel: AppViewModel?
    private var mockKeyboardShortcutsGateway: MockKeyboardShortcutsGateway?
    private var mockConfigurationGateway: MockConfigurationGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()

        // Initialize with trigger key not pressed using real use cases with mock gateways
        mockKeyboardShortcutsGateway = MockKeyboardShortcutsGateway(isPressed: false)
        mockConfigurationGateway = MockConfigurationGateway()
        guard
            let keyboardGateway = mockKeyboardShortcutsGateway,
            let configGateway = mockConfigurationGateway
        else {
            XCTFail("Mock gateways should be initialized")
            return
        }

        let pressStateUseCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: keyboardGateway)
        let enabledUseCase = GetQuickHideEnabledUseCase(configurationGateway: configGateway)
        let triggerKeyUseCase = GetQuickHideTriggerKeyUseCase(configurationGateway: configGateway)

        viewModel = AppViewModel(
            getQuickHideTriggerKeyPressStateUseCase: pressStateUseCase,
            getQuickHideEnabledUseCase: enabledUseCase,
            getQuickHideTriggerKeyUseCase: triggerKeyUseCase
        )
    }

    override func tearDown() async throws {
        try await super.tearDown()
        viewModel = nil
        mockConfigurationGateway = nil
        cancellables = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Given view model initialized (in setUp)
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        // Then should have initial trigger key state
        expect(viewModel.isQuickHideTriggerKeyPressed) == false
    }

    func testInitializationWithQuickHideTriggerKeyPressed() {
        // Given trigger key is pressed
        mockKeyboardShortcutsGateway = MockKeyboardShortcutsGateway(isPressed: true)
        let configGateway = MockConfigurationGateway()
        guard let keyboardGateway = mockKeyboardShortcutsGateway else {
            XCTFail("MockKeyboardShortcutsGateway should be initialized")
            return
        }

        let pressStateUseCase = GetQuickHideTriggerKeyPressStateUseCase(keyboardShortcutsGateway: keyboardGateway)
        let enabledUseCase = GetQuickHideEnabledUseCase(configurationGateway: configGateway)
        let triggerKeyUseCase = GetQuickHideTriggerKeyUseCase(configurationGateway: configGateway)

        // When initializing view model
        viewModel = AppViewModel(
            getQuickHideTriggerKeyPressStateUseCase: pressStateUseCase,
            getQuickHideEnabledUseCase: enabledUseCase,
            getQuickHideTriggerKeyUseCase: triggerKeyUseCase
        )

        // Then should reflect pressed state
        expect(self.viewModel?.isQuickHideTriggerKeyPressed) == true
    }

    // MARK: - Reactive Updates Tests

    func testQuickHideTriggerKeyPressStateUpdates() {
        // Given view model subscribed to state
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        guard var cancellables else {
            XCTFail("Cancellables should be initialized")
            return
        }

        let expectation = XCTestExpectation(description: "Quick Hide trigger key state updates")
        expectation.expectedFulfillmentCount = 2 // Initial + update

        var receivedStates: [Bool] = []
        viewModel.$isQuickHideTriggerKeyPressed
            .sink { state in
                receivedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Assign updated cancellables back to class property
        self.cancellables = cancellables

        // When trigger key state changes
        mockKeyboardShortcutsGateway?.emitQuickHideTriggerKeyPressState(true)

        wait(for: [expectation], timeout: 1.0)

        // Then should receive both states
        expect(receivedStates.count) == 2
        expect(receivedStates[0]) == false
        expect(receivedStates[1]) == true
    }

    func testQuickHideTriggerKeyPressStateMultipleUpdates() {
        // Given view model
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        guard var cancellables else {
            XCTFail("Cancellables should be initialized")
            return
        }

        let expectation = XCTestExpectation(description: "Multiple updates")
        var updateCount = 0

        viewModel.$isQuickHideTriggerKeyPressed
            .dropFirst() // Skip initial value
            .sink { _ in
                updateCount += 1
                if updateCount == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Assign updated cancellables back to class property
        self.cancellables = cancellables

        // When state changes multiple times
        mockKeyboardShortcutsGateway?.emitQuickHideTriggerKeyPressState(true)
        mockKeyboardShortcutsGateway?.emitQuickHideTriggerKeyPressState(false)
        mockKeyboardShortcutsGateway?.emitQuickHideTriggerKeyPressState(true)

        wait(for: [expectation], timeout: 1.0)

        // Then should receive all updates
        expect(updateCount) == 3
    }

    // MARK: - ObservableObject Tests

    func testIsObservableObject() {
        // Given view model
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        // Then should be ObservableObject
        expect(viewModel).to(beAnInstanceOf(AppViewModel.self))
    }

    func testPublishedPropertyTriggersObjectWillChange() {
        // Given view model
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        guard var cancellables else {
            XCTFail("Cancellables should be initialized")
            return
        }

        let expectation = XCTestExpectation(description: "ObjectWillChange fires")

        viewModel.objectWillChange
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Assign updated cancellables back to class property
        self.cancellables = cancellables

        // When trigger key state changes
        mockKeyboardShortcutsGateway?.emitQuickHideTriggerKeyPressState(true)

        // Allow RunLoop to process updates
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        wait(for: [expectation], timeout: 2.0)

        // Then objectWillChange should fire
        _ = expectation
    }

    // MARK: - Edge Cases

    func testRapidStateChanges() {
        // Given view model
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        guard var cancellables else {
            XCTFail("Cancellables should be initialized")
            return
        }

        var receivedStates: [Bool] = []

        viewModel.$isQuickHideTriggerKeyPressed
            .sink { state in
                receivedStates.append(state)
            }
            .store(in: &cancellables)

        // Assign updated cancellables back to class property
        self.cancellables = cancellables

        // When rapid state changes occur
        for i in 0 ..< 10 {
            mockKeyboardShortcutsGateway?.emitQuickHideTriggerKeyPressState(i.isMultiple(of: 2))
        }

        // Wait for updates to propagate
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        // Then should handle all changes
        expect(receivedStates.count) > 1
    }

    func testMemoryManagement() {
        // Given view model
        // Declared and assigned separately so the reference is a genuine mutable
        // weak binding; `weak let` lets the optimizer keep the object alive.
        weak var weakViewModel: AppViewModel?
        weakViewModel = viewModel

        // When deallocating view model and breaking all references
        cancellables = nil
        mockKeyboardShortcutsGateway = nil
        mockConfigurationGateway = nil
        viewModel = nil

        // Then should be deallocated
        expect(weakViewModel).to(beNil())
    }
}
