// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Domain
import Nimble
import XCTest

/// Tests parsing of AeroSpace version strings and the capability check that
/// decides between event subscription and the legacy callback path.
final class AeroSpaceVersionTests: XCTestCase {
    // MARK: - Parsing

    func testParsesReleaseVersionWithSuffix() {
        // Given the format AeroSpace actually reports
        let version = AeroSpaceVersion(string: "0.21.3-Beta")

        // Then the numeric prefix is parsed and the suffix ignored
        expect(version) == AeroSpaceVersion(major: 0, minor: 21, patch: 3)
    }

    func testParsesPlainVersion() {
        // Given a bare version triple
        let version = AeroSpaceVersion(string: "1.2.3")

        // Then every component is parsed
        expect(version) == AeroSpaceVersion(major: 1, minor: 2, patch: 3)
    }

    func testParsesVersionWithLeadingV() {
        // Given a tag-style version string
        let version = AeroSpaceVersion(string: "v0.13.0")

        // Then the leading marker is ignored
        expect(version) == AeroSpaceVersion(major: 0, minor: 13, patch: 0)
    }

    func testParsesVersionWithMissingPatch() {
        // Given a version with no patch component
        let version = AeroSpaceVersion(string: "0.21")

        // Then the patch defaults to zero
        expect(version) == AeroSpaceVersion(major: 0, minor: 21, patch: 0)
    }

    func testReturnsNilForUnparseableString() {
        // Given strings carrying no numeric version
        // Then parsing fails rather than guessing
        expect(AeroSpaceVersion(string: "unknown")).to(beNil())
        expect(AeroSpaceVersion(string: "")).to(beNil())
        expect(AeroSpaceVersion(string: nil)).to(beNil())
    }

    // MARK: - Ordering

    func testOrdersByMajorThenMinorThenPatch() {
        // Given versions differing in each component
        // Then ordering follows semantic version precedence
        expect(AeroSpaceVersion(major: 0, minor: 21, patch: 0))
            .to(beLessThan(AeroSpaceVersion(major: 1, minor: 0, patch: 0)))
        expect(AeroSpaceVersion(major: 0, minor: 20, patch: 9))
            .to(beLessThan(AeroSpaceVersion(major: 0, minor: 21, patch: 0)))
        expect(AeroSpaceVersion(major: 0, minor: 21, patch: 1))
            .to(beLessThan(AeroSpaceVersion(major: 0, minor: 21, patch: 2)))
    }

    // MARK: - Event Subscription Capability

    func testVersionsBelowMinimumDoNotSupportEventSubscription() {
        // Given AeroSpace versions predating the subscribe command
        // Then the legacy path must be used
        expect(AeroSpaceVersion(string: "0.20.3-Beta")?.supportsEventSubscription) == false
        expect(AeroSpaceVersion(string: "0.13.0")?.supportsEventSubscription) == false
    }

    func testMinimumVersionSupportsEventSubscription() {
        // Given the first release that shipped `aerospace subscribe`
        // Then subscription is available
        expect(AeroSpaceVersion(string: "0.21.0-Beta")?.supportsEventSubscription) == true
    }

    func testNewerVersionsSupportEventSubscription() {
        // Given releases after the minimum
        // Then subscription remains available
        expect(AeroSpaceVersion(string: "0.21.3-Beta")?.supportsEventSubscription) == true
        expect(AeroSpaceVersion(string: "1.0.0")?.supportsEventSubscription) == true
    }
}
