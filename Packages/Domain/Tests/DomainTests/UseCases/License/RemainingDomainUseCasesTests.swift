// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for remaining Domain use cases.
///
/// These tests cover Spaces, FeatureFlags, KeyboardShortcuts, and SoftwareUpdate use cases.
@MainActor
final class RemainingDomainUseCasesTests: XCTestCase {
    private var mockSpacesGateway: MockSpacesGateway?
    private var mockFeatureFlagsGateway: MockFeatureFlagsGateway?
    private var mockKeyboardGateway: MockKeyboardShortcutsGateway?
    private var mockSoftwareUpdateGateway: MockSoftwareUpdateGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockSpacesGateway = MockSpacesGateway()
        mockFeatureFlagsGateway = MockFeatureFlagsGateway()
        mockKeyboardGateway = MockKeyboardShortcutsGateway()
        mockSoftwareUpdateGateway = MockSoftwareUpdateGateway()
        cancellables = []
    }

    // MARK: - Spaces Use Case Tests

    func testGetAeroSpaceStatus() async {
        guard
            let mockSpacesGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockSpacesGateway.isAeroSpaceRunning = true
        let useCase = GetAeroSpaceStatusUseCase(spacesGateway: mockSpacesGateway)

        // When
        var result: Bool?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == true
    }

    func testStartAeroSpace() async {
        guard
            let mockSpacesGateway
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = StartAeroSpaceUseCase(spacesGateway: mockSpacesGateway)

        // When
        do {
            try await useCase.execute()
        } catch {
            XCTFail("Expected execution to succeed, but got error: \(error)")
        }

        // Then
        expect(mockSpacesGateway.startAeroSpaceCallCount) == 1
    }

    // MARK: - FeatureFlags Use Case Tests

    func testGetFeatureFlags() async {
        guard
            let mockFeatureFlagsGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectedFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )
        mockFeatureFlagsGateway.featureFlagsToEmit = expectedFlags
        let useCase = GetFeatureFlagsUseCase(gateway: mockFeatureFlagsGateway)

        // When
        var result: FeatureFlags?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result?.enableGroups) == true
        expect(result?.enableSpaces) == true
        expect(result?.enableAdvancedSettings) == false
        expect(result?.enableSoftwareUpdates) == true
    }

    func testSetFeatureFlags() {
        guard
            let mockFeatureFlagsGateway
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let flags = FeatureFlags(
            enableGroups: false,
            enableSpaces: true,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: true
        )
        let useCase = SetFeatureFlagsUseCase(gateway: mockFeatureFlagsGateway)

        // When
        useCase.execute(flags: flags)

        // Then
        expect(mockFeatureFlagsGateway.setFeatureFlagsCalls.count) == 1
        expect(mockFeatureFlagsGateway.setFeatureFlagsCalls.first?.enableGroups) == false
        expect(mockFeatureFlagsGateway.setFeatureFlagsCalls.first?.enableSpaces) == true
        expect(mockFeatureFlagsGateway.setFeatureFlagsCalls.first?.enableAdvancedSettings) == true
        expect(mockFeatureFlagsGateway.setFeatureFlagsCalls.first?.enableSoftwareUpdates) == false
    }

    // MARK: - KeyboardShortcuts Use Case Tests

    func testGetGlobeKeyPressState() async {
        guard
            let mockKeyboardGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockKeyboardGateway.globeKeyPressStateToEmit = true
        let useCase = GetGlobeKeyPressStateUseCase(keyboardShortcutsGateway: mockKeyboardGateway)

        // When
        var result: Bool?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == true
    }

    // MARK: - SoftwareUpdate Use Case Tests

    func testCheckForUpdates() async {
        guard
            let mockSoftwareUpdateGateway
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = CheckForUpdatesUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)

        // When
        await useCase.execute()

        // Then
        expect(mockSoftwareUpdateGateway.checkForUpdatesCalls) == 1
    }

    func testGetAutomaticCheckForUpdatesEnabled() async {
        guard
            let mockSoftwareUpdateGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockSoftwareUpdateGateway.automaticCheckForUpdatesEnabledToEmit = true
        let useCase = GetAutomaticCheckForUpdatesEnabledUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)

        // When
        var result: Bool?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == true
    }

    func testSetAutomaticCheckForUpdatesEnabled() async {
        guard
            let mockSoftwareUpdateGateway
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetAutomaticCheckForUpdatesEnabledUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)

        // When
        await useCase.execute(enabled: false)

        // Then
        expect(mockSoftwareUpdateGateway.setAutomaticCheckForUpdatesEnabledCalls.count) == 1
        expect(mockSoftwareUpdateGateway.setAutomaticCheckForUpdatesEnabledCalls.first) == false
    }

    func testGetAutomaticDownloadUpdatesEnabled() async {
        guard
            let mockSoftwareUpdateGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        mockSoftwareUpdateGateway.automaticDownloadUpdatesEnabledToEmit = false
        let useCase = GetAutomaticDownloadUpdatesEnabledUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)

        // When
        var result: Bool?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == false
    }

    func testSetAutomaticDownloadUpdatesEnabled() async {
        guard
            let mockSoftwareUpdateGateway
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let useCase = SetAutomaticDownloadUpdatesEnabledUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)

        // When
        await useCase.execute(enabled: true)

        // Then
        expect(mockSoftwareUpdateGateway.setAutomaticDownloadUpdatesEnabledCalls.count) == 1
        expect(mockSoftwareUpdateGateway.setAutomaticDownloadUpdatesEnabledCalls.first) == true
    }

    func testGetLastUpdateCheckDate() async {
        guard
            let mockSoftwareUpdateGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let testDate = Date(timeIntervalSince1970: 1_609_459_200) // Jan 1, 2021
        mockSoftwareUpdateGateway.lastUpdateCheckDateToEmit = testDate
        let useCase = GetLastUpdateCheckDateUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)

        // When
        var result: Date?
        useCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))

        // Then
        expect(result) == testDate
    }

    // MARK: - Integration Tests

    func testAeroSpaceLifecycle() async {
        guard
            let mockSpacesGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given use cases for AeroSpace lifecycle
        let statusUseCase = GetAeroSpaceStatusUseCase(spacesGateway: mockSpacesGateway)
        let startUseCase = StartAeroSpaceUseCase(spacesGateway: mockSpacesGateway)

        // When - Check if running
        mockSpacesGateway.isAeroSpaceRunning = false
        var isRunning: Bool?
        statusUseCase.execute()
            .sink { value in
                isRunning = value
            }
            .store(in: &cancellables)

        try? await Task.sleep(for: .milliseconds(100))
        expect(isRunning) == false

        // And - Start AeroSpace
        do {
            try await startUseCase.execute()
        } catch {
            XCTFail("Expected start AeroSpace to succeed, but got error: \(error)")
        }

        // Then - Should track both operations
        expect(mockSpacesGateway.startAeroSpaceCallCount) == 1
    }

    func testFeatureFlagsLifecycle() async {
        guard
            let mockFeatureFlagsGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given feature flags use cases
        let getUseCase = GetFeatureFlagsUseCase(gateway: mockFeatureFlagsGateway)
        let setUseCase = SetFeatureFlagsUseCase(gateway: mockFeatureFlagsGateway)

        // When - Get current flags
        let initialFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )
        mockFeatureFlagsGateway.featureFlagsToEmit = initialFlags

        var getResult: FeatureFlags?
        getUseCase.execute()
            .sink { flags in
                getResult = flags
            }
            .store(in: &cancellables)
        try? await Task.sleep(for: .milliseconds(100))

        expect(getResult?.enableGroups) == true

        // And - Update flags
        let updatedFlags = FeatureFlags(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: false
        )
        setUseCase.execute(flags: updatedFlags)

        // Then - Should track both operations
        expect(mockFeatureFlagsGateway.setFeatureFlagsCalls.count) == 1
    }

    func testSoftwareUpdateConfiguration() async {
        guard
            let mockSoftwareUpdateGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given software update use cases
        let getCheckUseCase = GetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockSoftwareUpdateGateway
        )
        let setCheckUseCase = SetAutomaticCheckForUpdatesEnabledUseCase(
            softwareUpdateGateway: mockSoftwareUpdateGateway
        )
        let getDownloadUseCase = GetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockSoftwareUpdateGateway
        )
        let setDownloadUseCase = SetAutomaticDownloadUpdatesEnabledUseCase(
            softwareUpdateGateway: mockSoftwareUpdateGateway
        )

        // When - Configure automatic updates
        await setCheckUseCase.execute(enabled: true)
        await setDownloadUseCase.execute(enabled: true)

        // And - Verify configuration
        mockSoftwareUpdateGateway.automaticCheckForUpdatesEnabledToEmit = true
        mockSoftwareUpdateGateway.automaticDownloadUpdatesEnabledToEmit = true

        var checkResult: Bool?
        getCheckUseCase.execute()
            .sink { value in
                checkResult = value
            }
            .store(in: &cancellables)

        var downloadResult: Bool?
        getDownloadUseCase.execute()
            .sink { value in
                downloadResult = value
            }
            .store(in: &cancellables)

        // Then - Should configure properly
        try? await Task.sleep(for: .milliseconds(100))
        expect(checkResult) == true
        expect(downloadResult) == true
        expect(mockSoftwareUpdateGateway.setAutomaticCheckForUpdatesEnabledCalls.count) == 1
        expect(mockSoftwareUpdateGateway.setAutomaticDownloadUpdatesEnabledCalls.count) == 1
    }

    func testKeyboardShortcutMonitoring() async {
        guard
            let mockKeyboardGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given keyboard shortcut use case
        let useCase = GetGlobeKeyPressStateUseCase(keyboardShortcutsGateway: mockKeyboardGateway)

        // When - Monitor different states
        let states: [Bool] = [true, false, true]

        for state in states {
            mockKeyboardGateway.globeKeyPressStateToEmit = state

            var result: Bool?
            useCase.execute()
                .sink { value in
                    result = value
                }
                .store(in: &cancellables)

            try? await Task.sleep(for: .milliseconds(100))
            expect(result) == state
        }

        // Then - Should receive all state changes
    }

    func testUpdateCheckWorkflow() async {
        guard
            let mockSoftwareUpdateGateway,
            var cancellables
        else {
            fail("Test dependencies not initialized")
            return
        }

        // Given update check use cases
        let checkUseCase = CheckForUpdatesUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)
        let getDateUseCase = GetLastUpdateCheckDateUseCase(softwareUpdateGateway: mockSoftwareUpdateGateway)

        // When - Check for updates
        await checkUseCase.execute()

        // And - Get last check date
        let testDate = Date()
        mockSoftwareUpdateGateway.lastUpdateCheckDateToEmit = testDate

        var dateResult: Date?
        getDateUseCase.execute()
            .sink { value in
                dateResult = value
            }
            .store(in: &cancellables)

        // Then - Should track check and provide date
        try? await Task.sleep(for: .milliseconds(100))
        expect(dateResult) == testDate
        expect(mockSoftwareUpdateGateway.checkForUpdatesCalls) == 1
    }
}
