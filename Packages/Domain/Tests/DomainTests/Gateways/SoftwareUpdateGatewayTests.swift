// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Foundation
import Nimble
import XCTest

/// Tests for SoftwareUpdateGateway protocol.
///
/// These tests verify:
/// - Protocol conformance
/// - Publisher requirements
/// - Automatic check for updates settings
/// - Automatic download settings
/// - Last update check date tracking
/// - Manual update check triggering
@MainActor
final class SoftwareUpdateGatewayTests: XCTestCase {
    private var sut: MockSoftwareUpdateGateway?
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() async throws {
        try await super.setUp()
        sut = MockSoftwareUpdateGateway()
        cancellables = []
    }

    override func tearDown() async throws {
        cancellables.removeAll()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Publisher Tests

    func testAutomaticCheckForUpdatesEnabledPublisher() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Publisher emits automatic check state")
        var receivedState: Bool?

        // When
        sut.automaticCheckForUpdatesEnabledPublisher
            .sink { enabled in
                receivedState = enabled
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState).toNot(beNil())
    }

    func testAutomaticDownloadUpdatesEnabledPublisher() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Publisher emits automatic download state")
        var receivedState: Bool?

        // When
        sut.automaticDownloadUpdatesEnabledPublisher
            .sink { enabled in
                receivedState = enabled
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState).toNot(beNil())
    }

    func testLastUpdateCheckDatePublisher() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        // Given
        let expectation = expectation(description: "Publisher emits last check date")
        var receivedDate: Date?
        var wasCalled = false

        // When
        sut.lastUpdateCheckDatePublisher
            .sink { date in
                receivedDate = date
                wasCalled = true
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(wasCalled) == true
        expect(receivedDate).to(beNil())
    }

    // MARK: - Set Automatic Check Tests

    func testSetAutomaticCheckForUpdatesEnabled() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Automatic check enabled updated")
        var receivedState: Bool?

        sut.automaticCheckForUpdatesEnabledPublisher
            .dropFirst() // Skip initial value
            .sink { enabled in
                receivedState = enabled
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.setAutomaticCheckForUpdatesEnabled(false)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState) == false
    }

    func testSetAutomaticCheckForUpdatesEnabledToggle() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        sut.setAutomaticCheckForUpdatesEnabled(false)

        let expectation = expectation(description: "Automatic check re-enabled")
        var receivedState: Bool?

        sut.automaticCheckForUpdatesEnabledPublisher
            .dropFirst() // Skip current value
            .sink { enabled in
                receivedState = enabled
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.setAutomaticCheckForUpdatesEnabled(true)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState) == true
    }

    // MARK: - Set Automatic Download Tests

    func testSetAutomaticDownloadUpdatesEnabled() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Automatic download enabled updated")
        var receivedState: Bool?

        sut.automaticDownloadUpdatesEnabledPublisher
            .dropFirst() // Skip initial value
            .sink { enabled in
                receivedState = enabled
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.setAutomaticDownloadUpdatesEnabled(true)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState) == true
    }

    func testSetAutomaticDownloadUpdatesEnabledToggle() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        sut.setAutomaticDownloadUpdatesEnabled(true)

        let expectation = expectation(description: "Automatic download disabled")
        var receivedState: Bool?

        sut.automaticDownloadUpdatesEnabledPublisher
            .dropFirst() // Skip current value
            .sink { enabled in
                receivedState = enabled
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.setAutomaticDownloadUpdatesEnabled(false)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        expect(receivedState) == false
    }

    // MARK: - Check for Updates Tests

    func testCheckForUpdates() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let initialDate = sut.lastUpdateCheckDateToEmit

        let expectation = expectation(description: "Last check date updated")
        var receivedDate: Date??

        sut.lastUpdateCheckDatePublisher
            .dropFirst() // Skip initial value
            .sink { date in
                receivedDate = date
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When
        sut.checkForUpdates()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        if let unwrappedReceivedDate = receivedDate, let date = unwrappedReceivedDate {
            if let unwrappedInitialDate = initialDate {
                expect(date) > unwrappedInitialDate
            }
        }
    }

    func testMultipleCheckForUpdates() async {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectation = expectation(description: "Multiple check dates")
        var receivedDates: [Date?] = []

        sut.lastUpdateCheckDatePublisher
            .sink { date in
                receivedDates.append(date)
                if receivedDates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.checkForUpdates()
        sut.checkForUpdates()

        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        expect(receivedDates.count) == 3 // Initial + 2 checks
    }

    // MARK: - Protocol Conformance Tests

    func testProtocolConformance() {
        guard let sut else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let gateway: any SoftwareUpdateGateway = sut

        // When/Then - Should compile and have publishers
        expect(gateway.automaticCheckForUpdatesEnabledPublisher).toNot(beNil())
        expect(gateway.automaticDownloadUpdatesEnabledPublisher).toNot(beNil())
        expect(gateway.lastUpdateCheckDatePublisher).toNot(beNil())
    }
}
