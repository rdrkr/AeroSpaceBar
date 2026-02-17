// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for CheckoutEnvironment enum.
///
/// These tests verify CheckoutEnvironment cases, display names, Codable conformance,
/// and CaseIterable protocol.
@MainActor
final class CheckoutEnvironmentTests: XCTestCase {
    // MARK: - Case Tests

    func testProductionCase() {
        // Given production environment
        let environment = CheckoutEnvironment.production

        // Then should match expected case
        expect(environment) == .production
        expect(environment.rawValue) == "production"
    }

    func testDevelopmentCase() {
        // Given development environment
        let environment = CheckoutEnvironment.development

        // Then should match expected case
        expect(environment) == .development
        expect(environment.rawValue) == "development"
    }

    // MARK: - Display Name Tests

    func testProductionDisplayName() {
        // Given production environment
        let environment = CheckoutEnvironment.production

        // Then should have correct display name
        expect(environment.displayName) == "Production"
    }

    func testDevelopmentDisplayName() {
        // Given development environment
        let environment = CheckoutEnvironment.development

        // Then should have correct display name
        expect(environment.displayName) == "Development"
    }

    // MARK: - CaseIterable Tests

    func testAllCases() {
        // Given all checkout environment cases
        let allCases = CheckoutEnvironment.allCases

        // Then should have 2 cases
        expect(allCases.count) == 2
        expect(allCases.contains(.production)) == true
        expect(allCases.contains(.development)) == true
    }

    func testIteratingAllCases() {
        // Given all cases
        var caseCount = 0

        // When iterating
        for _ in CheckoutEnvironment.allCases {
            caseCount += 1
        }

        // Then should iterate all 2
        expect(caseCount) == 2
    }

    // MARK: - Codable Tests

    func testEncodingAndDecoding() throws {
        // Given all checkout environments
        let environments = CheckoutEnvironment.allCases

        for environment in environments {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(environment)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(CheckoutEnvironment.self, from: data)

            // Then should match original
            expect(decoded) == environment
        }
    }

    func testRawValueCoding() throws {
        // Given production environment
        let environment = CheckoutEnvironment.production

        // When encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(environment)
        guard let jsonString = String(bytes: data, encoding: .utf8) else {
            XCTFail("Failed to convert data to string")
            return
        }

        // Then should encode as raw value
        expect(jsonString.contains("production")) == true
    }

    func testDecodingFromRawValue() throws {
        // Given JSON with raw value
        let json = "\"development\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let environment = try decoder.decode(CheckoutEnvironment.self, from: data)

        // Then should decode correctly
        expect(environment) == .development
    }

    func testDecodingInvalidValue() {
        // Given JSON with invalid value
        let json = "\"invalid\""

        // When decoding
        let data = Data(json.utf8)
        let decoder = JSONDecoder()

        // Then should throw decoding error
        expect { try decoder.decode(CheckoutEnvironment.self, from: data) }.to(throwError())
    }

    // MARK: - RawRepresentable Tests

    func testRawValueInitialization() {
        // Given raw values
        let production = CheckoutEnvironment(rawValue: "production")
        let development = CheckoutEnvironment(rawValue: "development")
        let invalid = CheckoutEnvironment(rawValue: "invalid")

        // Then should create correct environments
        expect(production) == .production
        expect(development) == .development
        expect(invalid).to(beNil())
    }

    // MARK: - Sendable Tests

    func testSendableConformance() {
        // CheckoutEnvironment conforms to Sendable
        Task {
            let environment = CheckoutEnvironment.production
            // If this compiles, Sendable conformance is working
            expect(environment).toNot(beNil())
        }
    }

    // MARK: - Pattern Matching Tests

    func testPatternMatchingProduction() {
        // Given all checkout environments
        let environments = CheckoutEnvironment.allCases

        // When checking which matches production
        let productionEnvironments = environments.filter { environment in
            switch environment {
            case .production:
                true

            case .development:
                false
            }
        }

        // Then should find exactly one production environment
        expect(productionEnvironments.count) == 1
        expect(productionEnvironments.first) == .production
    }

    func testPatternMatchingDevelopment() {
        // Given all checkout environments
        let environments = CheckoutEnvironment.allCases

        // When checking which matches development
        let developmentEnvironments = environments.filter { environment in
            switch environment {
            case .development:
                true

            case .production:
                false
            }
        }

        // Then should find exactly one development environment
        expect(developmentEnvironments.count) == 1
        expect(developmentEnvironments.first) == .development
    }

    // MARK: - Equality Tests

    func testEquality() {
        // Given same environments
        let env1 = CheckoutEnvironment.production
        let env2 = CheckoutEnvironment.production

        // Then should be equal
        expect(env1) == env2
    }

    func testInequality() {
        // Given different environments
        let env1 = CheckoutEnvironment.production
        let env2 = CheckoutEnvironment.development

        // Then should not be equal
        expect(env1) != env2
    }

    // MARK: - Hashable Tests

    func testHashableConformance() {
        // Given checkout environments
        let env1 = CheckoutEnvironment.production
        let env2 = CheckoutEnvironment.development

        // When adding to set
        let set: Set<CheckoutEnvironment> = [env1, env2]

        // Then should store unique environments
        expect(set.count) == 2
    }

    func testHashableWithDuplicates() {
        // Given duplicate environments
        let env1 = CheckoutEnvironment.production
        let env2 = CheckoutEnvironment.production

        // When adding to set
        let set: Set<CheckoutEnvironment> = [env1, env2]

        // Then should only store one
        expect(set.count) == 1
    }

    func testHashConsistency() {
        // Given same environments
        let env1 = CheckoutEnvironment.development
        let env2 = CheckoutEnvironment.development

        // Then hash values should be equal
        expect(env1.hashValue) == env2.hashValue
    }

    // MARK: - Usage Scenario Tests

    func testProductionEnvironmentForLivePayments() {
        // Given production environment
        let environment = CheckoutEnvironment.production

        // Then should be production for real payments
        expect(environment) == .production
        expect(environment.displayName) == "Production"
    }

    func testDevelopmentEnvironmentForTesting() {
        // Given development environment
        let environment = CheckoutEnvironment.development

        // Then should be development for testing
        expect(environment) == .development
        expect(environment.displayName) == "Development"
    }

    // MARK: - Edge Cases

    func testAllEnvironmentsHaveRawValues() {
        // Given all environments
        let environments = CheckoutEnvironment.allCases

        // Then all should have non-empty raw values
        for environment in environments {
            expect(environment.rawValue.isEmpty) == false
        }
    }

    func testRawValuesAreUnique() {
        // Given all environments
        let environments = CheckoutEnvironment.allCases
        let rawValues = environments.map(\.rawValue)

        // Then all raw values should be unique
        let uniqueRawValues = Set(rawValues)
        expect(rawValues.count) == uniqueRawValues.count
    }

    func testDisplayNamesAreUnique() {
        // Given all environments
        let environments = CheckoutEnvironment.allCases
        let displayNames = environments.map(\.displayName)

        // Then all display names should be unique
        let uniqueDisplayNames = Set(displayNames)
        expect(displayNames.count) == uniqueDisplayNames.count
    }

    func testRoundTripCodingForAllEnvironments() throws {
        // Given all environments
        for environment in CheckoutEnvironment.allCases {
            // When encoding and decoding
            let encoder = JSONEncoder()
            let data = try encoder.encode(environment)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(CheckoutEnvironment.self, from: data)

            // Then should match original
            expect(decoded) == environment
        }
    }
}
