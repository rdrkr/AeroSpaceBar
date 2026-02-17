// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for FeatureFlags UseCases.
///
/// These tests verify:
/// - GetFeatureFlagsUseCase
/// - SetFeatureFlagsUseCase
@MainActor
final class FeatureFlagsUseCaseTests: XCTestCase {
    private var mockGateway: MockFeatureFlagsGateway?
    private var cancellables: Set<AnyCancellable>?

    override func setUp() async throws {
        try await super.setUp()
        mockGateway = MockFeatureFlagsGateway()
        cancellables = []
    }

    // MARK: - GetFeatureFlagsUseCase Tests

    func testGetFeatureFlagsDefault() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let expectedFlags = FeatureFlags.defaultFlags()
        mockGateway.featureFlagsToEmit = expectedFlags
        let useCase = GetFeatureFlagsUseCase(gateway: mockGateway)
        var receivedFlags: FeatureFlags?

        // When
        useCase.execute()
            .sink { value in receivedFlags = value }
            .store(in: &cancellables)

        // Then
        expect(receivedFlags).toNot(beNil())
        expect(receivedFlags) == expectedFlags
    }

    func testGetFeatureFlagsWithCustomValues() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        var customFlags = FeatureFlags.defaultFlags()
        customFlags = customFlags.copy(
            enableGroups: customFlags.enableGroups,
            enableSpaces: customFlags.enableSpaces
        )
        mockGateway.featureFlagsToEmit = customFlags
        let useCase = GetFeatureFlagsUseCase(gateway: mockGateway)
        var receivedFlags: FeatureFlags?

        // When
        useCase.execute()
            .sink { value in receivedFlags = value }
            .store(in: &cancellables)

        // Then
        expect(receivedFlags).toNot(beNil())
        expect(receivedFlags) == customFlags
        expect(receivedFlags?.enableGroups) == FeatureFlags.defaultFlags().enableGroups
        expect(receivedFlags?.enableSpaces) == FeatureFlags.defaultFlags().enableSpaces
    }

    // MARK: - SetFeatureFlagsUseCase Tests

    func testSetFeatureFlagsEnablesAllFlags() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        var allEnabledFlags = FeatureFlags.defaultFlags()
        allEnabledFlags = allEnabledFlags.copy(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )
        let useCase = SetFeatureFlagsUseCase(gateway: mockGateway)

        // When
        useCase.execute(flags: allEnabledFlags)

        // Then
        expect(mockGateway.featureFlagsToEmit) == allEnabledFlags
        expect(mockGateway.featureFlagsToEmit.enableGroups) == true
        expect(mockGateway.featureFlagsToEmit.enableSpaces) == true
        expect(mockGateway.featureFlagsToEmit.enableSoftwareUpdates) == true
        expect(mockGateway.featureFlagsToEmit.enableAdvancedSettings) == true
    }

    func testSetFeatureFlagsDisablesAllFlags() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        var allDisabledFlags = FeatureFlags.defaultFlags()
        allDisabledFlags = allDisabledFlags.copy(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: false
        )
        let useCase = SetFeatureFlagsUseCase(gateway: mockGateway)

        // When
        useCase.execute(flags: allDisabledFlags)

        // Then
        expect(mockGateway.featureFlagsToEmit) == allDisabledFlags
        expect(mockGateway.featureFlagsToEmit.enableGroups) == false
        expect(mockGateway.featureFlagsToEmit.enableSpaces) == false
        expect(mockGateway.featureFlagsToEmit.enableSoftwareUpdates) == false
        expect(mockGateway.featureFlagsToEmit.enableAdvancedSettings) == false
    }

    func testSetFeatureFlagsPartialToggle() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        var partialFlags = FeatureFlags.defaultFlags()
        partialFlags = partialFlags.copy(
            enableGroups: true,
            enableSpaces: false
        )
        let useCase = SetFeatureFlagsUseCase(gateway: mockGateway)

        // When
        useCase.execute(flags: partialFlags)

        // Then
        expect(mockGateway.featureFlagsToEmit) == partialFlags
        expect(mockGateway.featureFlagsToEmit.enableGroups) == true
        expect(mockGateway.featureFlagsToEmit.enableSpaces) == false
    }

    // MARK: - ResetToDefaults Tests

    func testResetFeatureFlagsToDefaults() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        var customFlags = FeatureFlags.defaultFlags()
        customFlags = customFlags.copy(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: false
        )
        mockGateway.featureFlagsToEmit = customFlags
        let useCase = GetFeatureFlagsUseCase(gateway: mockGateway)

        // When
        mockGateway.resetToDefaults()
        var receivedFlags: FeatureFlags?
        useCase.execute()
            .sink { value in receivedFlags = value }
            .store(in: &cancellables)

        // Then
        let defaultFlags = FeatureFlags.defaultFlags()
        expect(mockGateway.featureFlagsToEmit) == defaultFlags
        expect(receivedFlags) == defaultFlags
    }

    func testSetFeatureFlagsUseCaseResetToDefaults() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let setUseCase = SetFeatureFlagsUseCase(gateway: mockGateway)
        var customFlags = FeatureFlags.defaultFlags()
        customFlags = customFlags.copy(enableGroups: false)
        setUseCase.execute(flags: customFlags)

        // When
        setUseCase.resetToDefaults()

        // Then
        expect(mockGateway.featureFlagsToEmit) == FeatureFlags.defaultFlags()
    }

    // MARK: - Integration Tests

    func testGetAndSetFeatureFlagsWorkflow() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let setUseCase = SetFeatureFlagsUseCase(gateway: mockGateway)
        let getUseCase = GetFeatureFlagsUseCase(gateway: mockGateway)

        var customFlags = FeatureFlags.defaultFlags()
        customFlags = customFlags.copy(
            enableGroups: customFlags.enableGroups
        )

        var receivedFlags: FeatureFlags?

        // When - Set custom flags
        setUseCase.execute(flags: customFlags)

        // When - Get flags
        getUseCase.execute()
            .sink { value in receivedFlags = value }
            .store(in: &cancellables)

        // Then
        expect(receivedFlags) == customFlags
        expect(mockGateway.featureFlagsToEmit) == customFlags
    }

    func testToggleSingleFlagMultipleTimes() {
        guard let mockGateway, var cancellables else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let setUseCase = SetFeatureFlagsUseCase(gateway: mockGateway)
        let getUseCase = GetFeatureFlagsUseCase(gateway: mockGateway)
        var receivedFlags: FeatureFlags?

        // When - First toggle
        var flags = FeatureFlags.defaultFlags()
        flags = flags.copy(enableGroups: true)
        setUseCase.execute(flags: flags)
        getUseCase.execute()
            .sink { value in receivedFlags = value }
            .store(in: &cancellables)

        // Then - Verify first toggle
        expect(receivedFlags?.enableGroups ?? false) == true

        // When - Toggle back
        cancellables.removeAll()
        flags = flags.copy(enableGroups: false)
        setUseCase.execute(flags: flags)
        var receivedFlagsAfterToggleBack: FeatureFlags?
        getUseCase.execute()
            .sink { value in receivedFlagsAfterToggleBack = value }
            .store(in: &cancellables)

        // Then - Verify toggle back
        expect(receivedFlagsAfterToggleBack?.enableGroups ?? true) == false
    }

    func testMultipleFeatureFlagsModifications() {
        guard let mockGateway else {
            fail("Test dependencies not initialized")
            return
        }

        // Given
        let setUseCase = SetFeatureFlagsUseCase(gateway: mockGateway)
        var flags = FeatureFlags.defaultFlags()

        // When - Modify multiple flags sequentially
        flags = flags.copy(enableGroups: true)
        setUseCase.execute(flags: flags)
        expect(mockGateway.featureFlagsToEmit.enableGroups) == true

        flags = flags.copy(enableSpaces: true)
        setUseCase.execute(flags: flags)
        expect(mockGateway.featureFlagsToEmit.enableSpaces) == true

        flags = flags.copy(enableSoftwareUpdates: false)
        setUseCase.execute(flags: flags)
        expect(mockGateway.featureFlagsToEmit.enableSoftwareUpdates) == false

        // Then - Verify final state
        expect(mockGateway.featureFlagsToEmit.enableGroups) == true
        expect(mockGateway.featureFlagsToEmit.enableSpaces) == true
        expect(mockGateway.featureFlagsToEmit.enableSoftwareUpdates) == false
    }
}
