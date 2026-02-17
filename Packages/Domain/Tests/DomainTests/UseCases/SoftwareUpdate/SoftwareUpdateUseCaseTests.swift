// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for SoftwareUpdate UseCases.
///
/// These tests verify:
/// - GetAutomaticCheckForUpdatesEnabledUseCase / SetAutomaticCheckForUpdatesEnabledUseCase
/// - GetAutomaticDownloadUpdatesEnabledUseCase / SetAutomaticDownloadUpdatesEnabledUseCase
/// - GetLastUpdateCheckDateUseCase
/// - CheckForUpdatesUseCase
@MainActor
final class SoftwareUpdateUseCaseTests: XCTestCase {
    private var mockGateway: MockSoftwareUpdateGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockSoftwareUpdateGateway()
        cancellables = []
    }

    // MARK: - GetAutomaticCheckForUpdatesEnabledUseCase Tests

    func testGetAutomaticCheckForUpdatesEnabledWhenDisabled() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.automaticCheckForUpdatesEnabledToEmit = false
        let useCase = GetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue ?? true) == false
    }

    func testGetAutomaticCheckForUpdatesEnabledWhenEnabled() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.automaticCheckForUpdatesEnabledToEmit = true
        let useCase = GetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue ?? false) == true
    }

    // MARK: - SetAutomaticCheckForUpdatesEnabledUseCase Tests

    func testSetAutomaticCheckForUpdatesEnabled() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        let newValue = true

        // When
        await useCase.execute(enabled: newValue)

        // Then
        expect(mockGateway.automaticCheckForUpdatesEnabledToEmit) == newValue
    }

    func testSetAutomaticCheckForUpdatesDisabled() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.automaticCheckForUpdatesEnabledToEmit = true
        let useCase = SetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        let newValue = false

        // When
        await useCase.execute(enabled: newValue)

        // Then
        expect(mockGateway.automaticCheckForUpdatesEnabledToEmit) == newValue
    }

    // MARK: - GetAutomaticDownloadUpdatesEnabledUseCase Tests

    func testGetAutomaticDownloadUpdatesEnabledWhenDisabled() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.automaticDownloadUpdatesEnabledToEmit = false
        let useCase = GetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue ?? true) == false
    }

    func testGetAutomaticDownloadUpdatesEnabledWhenEnabled() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.automaticDownloadUpdatesEnabledToEmit = true
        let useCase = GetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        var receivedValue: Bool?

        // When
        useCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then
        expect(receivedValue).toNot(beNil())
        expect(receivedValue ?? false) == true
    }

    // MARK: - SetAutomaticDownloadUpdatesEnabledUseCase Tests

    func testSetAutomaticDownloadUpdatesEnabled() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        let newValue = true

        // When
        await useCase.execute(enabled: newValue)

        // Then
        expect(mockGateway.automaticDownloadUpdatesEnabledToEmit) == newValue
    }

    func testSetAutomaticDownloadUpdatesDisabled() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.automaticDownloadUpdatesEnabledToEmit = true
        let useCase = SetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        let newValue = false

        // When
        await useCase.execute(enabled: newValue)

        // Then
        expect(mockGateway.automaticDownloadUpdatesEnabledToEmit) == newValue
    }

    // MARK: - GetLastUpdateCheckDateUseCase Tests

    func testGetLastUpdateCheckDateWhenNil() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.lastUpdateCheckDateToEmit = nil
        let useCase = GetLastUpdateCheckDateUseCase(softwareUpdateGateway: mockGateway)
        var receivedDate: Date?
        var wasCalled = false

        // When
        useCase.execute()
            .sink { value in
                receivedDate = value
                wasCalled = true
            }
            .store(in: &cancellables)

        // Then
        expect(wasCalled) == true
        expect(receivedDate).to(beNil())
    }

    func testGetLastUpdateCheckDateWithValue() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let testDate = Date()
        mockGateway.lastUpdateCheckDateToEmit = testDate
        let useCase = GetLastUpdateCheckDateUseCase(softwareUpdateGateway: mockGateway)
        var receivedDate: Date?

        // When
        useCase.execute()
            .sink { value in receivedDate = value }
            .store(in: &cancellables)

        // Then
        expect(receivedDate) == testDate
    }

    // MARK: - CheckForUpdatesUseCase Tests

    func testCheckForUpdatesUpdatesLastCheckDate() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.lastUpdateCheckDateToEmit = nil
        let useCase = CheckForUpdatesUseCase(softwareUpdateGateway: mockGateway)

        // When
        await useCase.execute()

        // Then
        expect(mockGateway.lastUpdateCheckDateToEmit).toNot(beNil())
    }

    func testCheckForUpdatesUpdatesExistingDate() async {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let oldDate = Date(timeIntervalSinceNow: -3_600) // 1 hour ago
        mockGateway.lastUpdateCheckDateToEmit = oldDate
        let useCase = CheckForUpdatesUseCase(softwareUpdateGateway: mockGateway)

        // When
        await useCase.execute()

        // Then
        expect(mockGateway.lastUpdateCheckDateToEmit).toNot(beNil())
        let newDate = mockGateway.lastUpdateCheckDateToEmit ?? Date()
        expect(newDate) > oldDate
    }

    // MARK: - Integration Tests

    func testAutomaticCheckForUpdatesToggle() async {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let setUseCase = SetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        let getUseCase = GetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        var receivedValue: Bool?

        // When - First enable
        await setUseCase.execute(enabled: true)
        getUseCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then - Verify enabled
        expect(receivedValue ?? false) == true

        // When - Disable again
        await setUseCase.execute(enabled: false)
        cancellables.removeAll()
        var receivedValueAfterDisable: Bool?
        getUseCase.execute()
            .sink { value in receivedValueAfterDisable = value }
            .store(in: &cancellables)

        // Then - Verify disabled
        expect(receivedValueAfterDisable ?? true) == false
    }

    func testAutomaticDownloadUpdatesToggle() async {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let setUseCase = SetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        let getUseCase = GetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        var receivedValue: Bool?

        // When - First enable
        await setUseCase.execute(enabled: true)
        getUseCase.execute()
            .sink { value in receivedValue = value }
            .store(in: &cancellables)

        // Then - Verify enabled
        expect(receivedValue ?? false) == true

        // When - Disable again
        await setUseCase.execute(enabled: false)
        cancellables.removeAll()
        var receivedValueAfterDisable: Bool?
        getUseCase.execute()
            .sink { value in receivedValueAfterDisable = value }
            .store(in: &cancellables)

        // Then - Verify disabled
        expect(receivedValueAfterDisable ?? true) == false
    }

    func testMultiplePublisherSubscriptions() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockGateway.automaticCheckForUpdatesEnabledToEmit = true
        mockGateway.automaticDownloadUpdatesEnabledToEmit = false
        mockGateway.lastUpdateCheckDateToEmit = Date()

        let checkUseCase = GetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        let downloadUseCase = GetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockGateway
        )
        let dateUseCase = GetLastUpdateCheckDateUseCase(softwareUpdateGateway: mockGateway)

        var receivedCheck: Bool?
        var receivedDownload: Bool?
        var receivedDate: Date?

        // When
        checkUseCase.execute()
            .sink { value in receivedCheck = value }
            .store(in: &cancellables)

        downloadUseCase.execute()
            .sink { value in receivedDownload = value }
            .store(in: &cancellables)

        dateUseCase.execute()
            .sink { value in receivedDate = value }
            .store(in: &cancellables)

        // Then
        expect(receivedCheck ?? false) == true
        expect(receivedDownload ?? true) == false
        expect(receivedDate).toNot(beNil())
    }
}
