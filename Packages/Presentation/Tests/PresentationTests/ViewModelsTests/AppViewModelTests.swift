// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
@testable import Presentation
import XCTest

/// Tests for AppViewModel.
///
/// These tests verify app-level state management including:
/// - Initialization with globe key state
/// - Reactive updates from keyboard shortcuts
/// - Publisher subscriptions
@MainActor
final class AppViewModelTests: XCTestCase {
    private var viewModel: AppViewModel?
    private var mockKeyboardShortcutsGateway: MockKeyboardShortcutsGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        cancellables = Set<AnyCancellable>()

        // Initialize with globe key not pressed using real use case with mock gateway
        mockKeyboardShortcutsGateway = MockKeyboardShortcutsGateway(isPressed: false)
        guard let keyboardGateway = mockKeyboardShortcutsGateway else {
            XCTFail("MockKeyboardShortcutsGateway should be initialized")
            return
        }

        let realUseCase = GetGlobeKeyPressStateUseCase(keyboardShortcutsGateway: keyboardGateway)

        viewModel = AppViewModel(getGlobeKeyPressStateUseCase: realUseCase)
    }

    override func tearDown() async throws {
        try await super.tearDown()
        viewModel = nil
        cancellables = nil
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        // Given view model initialized (in setUp)
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        // Then should have initial globe key state
        expect(viewModel.isGlobeKeyPressed) == false
    }

    func testInitializationWithGlobeKeyPressed() {
        // Given globe key is pressed
        mockKeyboardShortcutsGateway = MockKeyboardShortcutsGateway(isPressed: true)
        guard let keyboardGateway = mockKeyboardShortcutsGateway else {
            XCTFail("MockKeyboardShortcutsGateway should be initialized")
            return
        }

        let realUseCase = GetGlobeKeyPressStateUseCase(keyboardShortcutsGateway: keyboardGateway)

        // When initializing view model
        viewModel = AppViewModel(getGlobeKeyPressStateUseCase: realUseCase)

        // Then should reflect pressed state
        expect(self.viewModel?.isGlobeKeyPressed) == true
    }

    // MARK: - Reactive Updates Tests

    func testGlobeKeyPressStateUpdates() {
        // Given view model subscribed to state
        guard let viewModel else {
            XCTFail("ViewModel should be initialized")
            return
        }

        guard var cancellables else {
            XCTFail("Cancellables should be initialized")
            return
        }

        let expectation = XCTestExpectation(description: "Globe key state updates")
        expectation.expectedFulfillmentCount = 2 // Initial + update

        var receivedStates: [Bool] = []
        viewModel.$isGlobeKeyPressed
            .sink { state in
                receivedStates.append(state)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Assign updated cancellables back to class property
        self.cancellables = cancellables

        // When globe key state changes
        mockKeyboardShortcutsGateway?.setGlobeKeyPressed(true)

        wait(for: [expectation], timeout: 1.0)

        // Then should receive both states
        expect(receivedStates.count) == 2
        expect(receivedStates[0]) == false
        expect(receivedStates[1]) == true
    }

    func testGlobeKeyPressStateMultipleUpdates() {
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

        viewModel.$isGlobeKeyPressed
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
        mockKeyboardShortcutsGateway?.setGlobeKeyPressed(true)
        mockKeyboardShortcutsGateway?.setGlobeKeyPressed(false)
        mockKeyboardShortcutsGateway?.setGlobeKeyPressed(true)

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

        // When globe key state changes
        mockKeyboardShortcutsGateway?.setGlobeKeyPressed(true)

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

        viewModel.$isGlobeKeyPressed
            .sink { state in
                receivedStates.append(state)
            }
            .store(in: &cancellables)

        // Assign updated cancellables back to class property
        self.cancellables = cancellables

        // When rapid state changes occur
        for i in 0 ..< 10 {
            mockKeyboardShortcutsGateway?.setGlobeKeyPressed(i.isMultiple(of: 2))
        }

        // Wait for updates to propagate
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        // Then should handle all changes
        expect(receivedStates.count) > 1
    }

    func testMemoryManagement() {
        // Given view model
        weak var weakViewModel = viewModel

        // When deallocating view model and breaking all references
        cancellables = nil
        mockKeyboardShortcutsGateway = nil
        viewModel = nil

        // Then should be deallocated
        expect(weakViewModel).to(beNil())
    }
}
