// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for FeatureFlags struct.
///
/// These tests verify FeatureFlags initialization, default values, Equatable conformance,
/// Sendable conformance, and copy methods for license flag management.
@MainActor
final class FeatureFlagsTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitializationWithAllParameters() {
        // Given parameters
        let enableGroups = true
        let enableSpaces = false
        let enableSoftwareUpdates = true
        let enableAdvancedSettings = false

        // When creating feature flags
        let flags = FeatureFlags(
            enableGroups: enableGroups,
            enableSpaces: enableSpaces,
            enableSoftwareUpdates: enableSoftwareUpdates,
            enableAdvancedSettings: enableAdvancedSettings
        )

        // Then all properties should be set
        expect(flags.enableGroups) == enableGroups
        expect(flags.enableSpaces) == enableSpaces
        expect(flags.enableSoftwareUpdates) == enableSoftwareUpdates
        expect(flags.enableAdvancedSettings) == enableAdvancedSettings
    }

    func testAllFlagsEnabled() {
        // Given all flags enabled
        let flags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )

        // Then all should be true
        expect(flags.enableGroups) == true
        expect(flags.enableSpaces) == true
        expect(flags.enableSoftwareUpdates) == true
        expect(flags.enableAdvancedSettings) == true
    }

    func testAllFlagsDisabled() {
        // Given all flags disabled
        let flags = FeatureFlags(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: false
        )

        // Then all should be false
        expect(flags.enableGroups) == false
        expect(flags.enableSpaces) == false
        expect(flags.enableSoftwareUpdates) == false
        expect(flags.enableAdvancedSettings) == false
    }

    // MARK: - Default Flags Tests

    func testDefaultFlags() {
        // When creating default flags
        let flags = FeatureFlags.defaultFlags()

        // Then should match defaults
        expect(flags.enableGroups) == FeatureFlagDefaults.enableGroups
        expect(flags.enableSpaces) == FeatureFlagDefaults.enableSpaces
        expect(flags.enableSoftwareUpdates) == FeatureFlagDefaults.enableSoftwareUpdates
        expect(flags.enableAdvancedSettings) == FeatureFlagDefaults.enableAdvancedSettings
    }

    // MARK: - Copy Methods Tests

    func testCopyWithDisabledRequiredLicenseFlags() {
        // Given flags with all features enabled
        let flags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )

        // When disabling required license flags
        let disabledFlags = flags.copyWithDisabledRequiredLicenseFlags()

        // Then required flags should be disabled
        expect(disabledFlags.enableGroups) == false
        expect(disabledFlags.enableSpaces) == false
        // Advanced settings should be disabled (requires license)
        expect(disabledFlags.enableAdvancedSettings) == false

        // But non-required flags should remain unchanged
        // Software updates should remain enabled (doesn't require license)
        expect(disabledFlags.enableSoftwareUpdates) == true
    }

    func testCopyWithUpdatedNonRequiredLicenseFlags() {
        // Given original flags
        let originalFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: true
        )

        // And other flags with different software updates setting
        let otherFlags = FeatureFlags(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        // When copying with updated non-required flags
        let updatedFlags = originalFlags.copyWithUpdatedNonRequiredLicenseFlags(other: otherFlags)

        // Then only software updates should be updated
        expect(updatedFlags.enableGroups) == true
        expect(updatedFlags.enableSpaces) == true
        expect(updatedFlags.enableSoftwareUpdates) == true
        expect(updatedFlags.enableAdvancedSettings) == true
    }

    func testCopyWithUpdatedNonRequiredLicenseFlagsNoChange() {
        // Given original flags
        let originalFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )

        // And other flags with same software updates setting
        let otherFlags = FeatureFlags(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        // When copying with updated non-required flags
        let updatedFlags = originalFlags.copyWithUpdatedNonRequiredLicenseFlags(other: otherFlags)

        // Then should return same instance (no changes needed)
        expect(updatedFlags) == originalFlags
    }

    // MARK: - Equatable Tests

    func testEqualityWithSameValues() {
        // Given two flags with same values
        let flags1 = FeatureFlags(
            enableGroups: true,
            enableSpaces: false,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        let flags2 = FeatureFlags(
            enableGroups: true,
            enableSpaces: false,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        // Then they should be equal
        expect(flags1) == flags2
    }

    func testInequalityWithDifferentGroups() {
        // Given two flags with different groups
        let flags1 = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )
        let flags2 = FeatureFlags(
            enableGroups: false,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )

        // Then they should not be equal
        expect(flags1) != flags2
    }

    func testInequalityWithDifferentSpaces() {
        // Given two flags with different spaces
        let flags1 = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )
        let flags2 = FeatureFlags(
            enableGroups: true,
            enableSpaces: false,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )

        // Then they should not be equal
        expect(flags1) != flags2
    }

    func testInequalityWithDifferentSoftwareUpdates() {
        // Given two flags with different software updates
        let flags1 = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )
        let flags2 = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: true
        )

        // Then they should not be equal
        expect(flags1) != flags2
    }

    func testInequalityWithDifferentAdvancedSettings() {
        // Given two flags with different advanced settings
        let flags1 = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )
        let flags2 = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        // Then they should not be equal
        expect(flags1) != flags2
    }

    // MARK: - Sendable Tests

    func testSendableConformance() {
        // FeatureFlags conforms to Sendable
        Task {
            let flags = FeatureFlags.defaultFlags()
            // If this compiles, Sendable conformance is working
            expect(flags).toNot(beNil())
        }
    }

    // MARK: - ModifiedCopy Macro Tests

    func testCopyMethodFromMacro() {
        // Given original flags
        let original = FeatureFlags(
            enableGroups: true,
            enableSpaces: false,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        // When using copy method from macro
        let modified = original.copy(enableSpaces: true)

        // Then should have updated value
        expect(modified.enableGroups) == true
        expect(modified.enableSpaces) == true
        expect(modified.enableSoftwareUpdates) == true
        expect(modified.enableAdvancedSettings) == false
    }

    func testCopyMultipleProperties() {
        // Given original flags
        let original = FeatureFlags(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: false,
            enableAdvancedSettings: false
        )

        // When using copy to change multiple properties
        let modified = original.copy(
            enableGroups: true,
            enableSpaces: true,
            enableAdvancedSettings: true
        )

        // Then should have updated values
        expect(modified.enableGroups) == true
        expect(modified.enableSpaces) == true
        expect(modified.enableSoftwareUpdates) == false
        expect(modified.enableAdvancedSettings) == true
    }

    // MARK: - Integration Tests

    func testLicenseActivationScenario() {
        // Given disabled flags (no license)
        let noLicenseFlags = FeatureFlags(
            enableGroups: false,
            enableSpaces: false,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        // When activating license (enabling all features)
        let licensedFlags = noLicenseFlags.copy(
            enableGroups: true,
            enableSpaces: true,
            enableAdvancedSettings: true
        )

        // Then required features should be enabled
        expect(licensedFlags.enableGroups) == true
        expect(licensedFlags.enableSpaces) == true
        expect(licensedFlags.enableAdvancedSettings) == true
        expect(licensedFlags.enableSoftwareUpdates) == true
    }

    func testLicenseDeactivationScenario() {
        // Given enabled flags (with license)
        let licensedFlags = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )

        // When deactivating license
        let noLicenseFlags = licensedFlags.copyWithDisabledRequiredLicenseFlags()

        // Then required features should be disabled
        expect(noLicenseFlags.enableGroups) == false
        expect(noLicenseFlags.enableSpaces) == false
        expect(noLicenseFlags.enableAdvancedSettings) == false
        expect(noLicenseFlags.enableSoftwareUpdates) == true
    }

    // MARK: - Edge Cases

    func testMixedFlagConfiguration() {
        // Given mixed flag configuration
        let flags = FeatureFlags(
            enableGroups: true,
            enableSpaces: false,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: false
        )

        // Then should allow any combination
        expect(flags.enableGroups) == true
        expect(flags.enableSpaces) == false
        expect(flags.enableSoftwareUpdates) == true
        expect(flags.enableAdvancedSettings) == false
    }

    func testCopyPreservesOriginal() {
        // Given original flags
        let original = FeatureFlags(
            enableGroups: true,
            enableSpaces: true,
            enableSoftwareUpdates: true,
            enableAdvancedSettings: true
        )

        // When copying and modifying
        let modified = original.copy(enableGroups: false)

        // Then original should be unchanged
        expect(original.enableGroups) == true
        expect(modified.enableGroups) == false
    }
}
