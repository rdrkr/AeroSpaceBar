// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

final class LicenseStatusTests: XCTestCase {
    // MARK: - Case Tests

    func testTrialCase() {
        // Given trial status with days remaining
        let status = LicenseStatus.trial(daysRemaining: 10)

        // Then should match expected case
        if case let .trial(days) = status {
            expect(days) == 10
        } else {
            XCTFail("Expected trial case")
        }
    }

    func testLicensedCase() {
        // Given licensed status
        let status = LicenseStatus.licensed

        // Then should match expected case
        expect(status) == .licensed
    }

    func testExpiredCase() {
        // Given expired status
        let status = LicenseStatus.expired

        // Then should match expected case
        expect(status) == .expired
    }

    func testValidatingCase() {
        // Given validating status
        let status = LicenseStatus.validating

        // Then should match expected case
        expect(status) == .validating
    }

    func testUnknownCase() {
        // Given unknown status
        let status = LicenseStatus.unknown

        // Then should match expected case
        expect(status) == .unknown
    }

    // MARK: - Equality Tests

    func testEqualityForLicensedStatus() {
        // Given two licensed statuses
        let status1 = LicenseStatus.licensed
        let status2 = LicenseStatus.licensed

        // Then they should be equal
        expect(status1) == status2
    }

    func testEqualityForTrialWithSameDays() {
        // Given two trial statuses with same days
        let status1 = LicenseStatus.trial(daysRemaining: 5)
        let status2 = LicenseStatus.trial(daysRemaining: 5)

        // Then they should be equal
        expect(status1) == status2
    }

    func testInequalityForTrialWithDifferentDays() {
        // Given two trial statuses with different days
        let status1 = LicenseStatus.trial(daysRemaining: 5)
        let status2 = LicenseStatus.trial(daysRemaining: 10)

        // Then they should not be equal
        expect(status1) != status2
    }

    func testInequalityBetweenDifferentCases() {
        // Given different status cases
        let licensed = LicenseStatus.licensed
        let expired = LicenseStatus.expired
        let unknown = LicenseStatus.unknown
        let validating = LicenseStatus.validating
        let trial = LicenseStatus.trial(daysRemaining: 5)

        // Then they should all be different
        expect(licensed) != expired
        expect(licensed) != unknown
        expect(licensed) != validating
        expect(licensed) != trial
        expect(expired) != unknown
        expect(expired) != validating
        expect(expired) != trial
        expect(unknown) != validating
        expect(unknown) != trial
        expect(validating) != trial
    }

    // MARK: - Coding Tests

    func testEncodeLicensedStatus() throws {
        // Given licensed status
        let status = LicenseStatus.licensed

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)

        // Then should encode successfully
        expect(data).toNot(beEmpty())

        // And should be decodable
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LicenseStatus.self, from: data)
        expect(decoded) == .licensed
    }

    func testEncodeTrialStatus() throws {
        // Given trial status
        let status = LicenseStatus.trial(daysRemaining: 7)

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)

        // Then should encode successfully
        expect(data).toNot(beEmpty())

        // And should be decodable
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LicenseStatus.self, from: data)
        expect(decoded) == .trial(daysRemaining: 7)
    }

    func testEncodeExpiredStatus() throws {
        // Given expired status
        let status = LicenseStatus.expired

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)

        // Then should encode and decode correctly
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LicenseStatus.self, from: data)
        expect(decoded) == .expired
    }

    func testEncodeValidatingStatus() throws {
        // Given validating status
        let status = LicenseStatus.validating

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)

        // Then should encode and decode correctly
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LicenseStatus.self, from: data)
        expect(decoded) == .validating
    }

    func testEncodeUnknownStatus() throws {
        // Given unknown status
        let status = LicenseStatus.unknown

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(status)

        // Then should encode and decode correctly
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LicenseStatus.self, from: data)
        expect(decoded) == .unknown
    }

    func testRoundTripCodingForAllCases() throws {
        // Given all status cases
        let statuses: [LicenseStatus] = [
            .licensed,
            .trial(daysRemaining: 14),
            .trial(daysRemaining: 1),
            .trial(daysRemaining: 0),
            .expired,
            .validating,
            .unknown
        ]

        for status in statuses {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(status)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(LicenseStatus.self, from: data)

            // Then should match original
            expect(decoded) == status
        }
    }

    // MARK: - Edge Cases

    func testTrialWithZeroDays() {
        // Given trial with 0 days
        let status = LicenseStatus.trial(daysRemaining: 0)

        // Then should be valid (0 days is technically still a trial)
        if case let .trial(days) = status {
            expect(days) == 0
        } else {
            XCTFail("Expected trial case")
        }
    }

    func testTrialWithNegativeDays() {
        // Given trial with negative days (shouldn't happen but test anyway)
        let status = LicenseStatus.trial(daysRemaining: -5)

        // Then should preserve the value
        if case let .trial(days) = status {
            expect(days) == -5
        } else {
            XCTFail("Expected trial case")
        }
    }

    func testTrialWithLargeDays() {
        // Given trial with very large days
        let status = LicenseStatus.trial(daysRemaining: 365)

        // Then should handle it correctly
        if case let .trial(days) = status {
            expect(days) == 365
        } else {
            XCTFail("Expected trial case")
        }
    }

    // MARK: - Pattern Matching Tests

    func testPatternMatchingForLicensed() {
        // Given all license statuses
        let allStatuses: [LicenseStatus] = [.licensed, .trial(daysRemaining: 10), .expired, .validating, .unknown]

        // When checking which matches licensed
        let licensedStatuses = allStatuses.filter { status in
            switch status {
            case .licensed:
                true

            case .trial,
                 .expired,
                 .validating,
                 .unknown:
                false
            }
        }

        // Then should find exactly one licensed status
        expect(licensedStatuses.count) == 1
        expect(licensedStatuses.first) == .licensed
    }

    func testPatternMatchingForTrial() {
        // Given all license statuses
        let allStatuses: [LicenseStatus] = [.licensed, .trial(daysRemaining: 10), .expired, .validating, .unknown]

        // When checking which matches trial and extracting days
        let trialResults = allStatuses.compactMap { status -> Int? in
            switch status {
            case let .trial(days):
                days

            case .licensed,
                 .expired,
                 .validating,
                 .unknown:
                nil
            }
        }

        // Then should find exactly one trial status with correct days
        expect(trialResults.count) == 1
        expect(trialResults.first) == 10
    }

    func testPatternMatchingForExpired() {
        // Given all license statuses
        let allStatuses: [LicenseStatus] = [.licensed, .trial(daysRemaining: 10), .expired, .validating, .unknown]

        // When checking which matches expired
        let expiredStatuses = allStatuses.filter { status in
            switch status {
            case .expired:
                true

            case .licensed,
                 .trial,
                 .validating,
                 .unknown:
                false
            }
        }

        // Then should find exactly one expired status
        expect(expiredStatuses.count) == 1
        expect(expiredStatuses.first) == .expired
    }

    // MARK: - Sendable Conformance Tests

    func testSendableConformance() {
        // LicenseStatus conforms to Sendable, so it can be safely passed between actors
        // This test verifies that the type system accepts it

        Task { @MainActor in
            let status = LicenseStatus.licensed
            // If this compiles, Sendable conformance is working
            expect(status) == .licensed
        }
    }

    // MARK: - Integration with LicenseInfo

    func testUsedInLicenseInfo() {
        // Given a LicenseInfo with different statuses
        let licensed = LicenseInfo(licenseStatus: .licensed)
        let trial = LicenseInfo(licenseStatus: .trial(daysRemaining: 5))
        let expired = LicenseInfo(licenseStatus: .expired)

        // Then statuses should be correctly stored
        expect(licensed.licenseStatus) == .licensed
        expect(trial.licenseStatus) == .trial(daysRemaining: 5)
        expect(expired.licenseStatus) == .expired
    }

    // MARK: - Critical Bug Fix Tests

    func testExpiredStatusDistinctFromLicensed() {
        // This tests the fix: expired and licensed are different states
        let expired = LicenseStatus.expired
        let licensed = LicenseStatus.licensed

        // Then they should be completely different
        expect(expired) != licensed

        // And expired should never equal licensed
        expect(expired == licensed) == false
        expect(expired != licensed) == true
    }

    func testTrialExpirationDoesNotAffectLicensedStatus() {
        // Given licensed status (purchased, not trial)
        let licensedStatus = LicenseStatus.licensed

        // Then it should never change to trial or expired on its own
        // (This is a conceptual test - the type system prevents this)
        expect(licensedStatus) == .licensed
        expect(licensedStatus) != .expired
        expect(licensedStatus) != .trial(daysRemaining: 0)
    }

    func testExpiredCanRepresentBothTrialAndPurchasedExpiration() {
        // The .expired case doesn't distinguish between expired trial and expired purchased
        // This was part of the original bug - we need to know the variant type separately

        let expiredFromTrial = LicenseStatus.expired
        let expiredFromPurchased = LicenseStatus.expired

        // They are the same status
        expect(expiredFromTrial) == expiredFromPurchased

        // But the fix ensures we check variant type BEFORE setting .expired
        // (tested in repository/use case tests)
    }
}
