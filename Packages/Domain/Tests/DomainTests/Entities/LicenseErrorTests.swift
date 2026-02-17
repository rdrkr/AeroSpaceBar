// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for LicenseError enum.
///
/// These tests verify LicenseError cases, error descriptions, LocalizedError conformance,
/// and pattern matching for license management.
@MainActor
final class LicenseErrorTests: XCTestCase {
    // MARK: - Case Tests

    func testInvalidLicenseKeyCase() {
        // Given invalid license key error
        let error = LicenseError.invalidLicenseKey

        // Then should match expected case
        expect(error) == .invalidLicenseKey
    }

    func testNetworkErrorCase() {
        // Given network error with underlying error
        struct MockNetworkError: Error { }
        let underlyingError = MockNetworkError()
        let error = LicenseError.networkError(underlyingError)

        // Then should match expected case with error
        if case .networkError = error {
            // Success - error matches expected case
        } else {
            XCTFail("Expected networkError case")
        }
    }

    func testValidationFailedCase() {
        // Given validation failed error
        let error = LicenseError.validationFailed

        // Then should match expected case
        expect(error) == .validationFailed
    }

    func testTrialAlreadyStartedCase() {
        // Given trial already started error
        let error = LicenseError.trialAlreadyStarted

        // Then should match expected case
        expect(error) == .trialAlreadyStarted
    }

    func testTrialAlreadyUsedCase() {
        // Given trial already used error
        let error = LicenseError.trialAlreadyUsed

        // Then should match expected case
        expect(error) == .trialAlreadyUsed
    }

    func testLicenseExpiredCase() {
        // Given license expired error
        let error = LicenseError.licenseExpired

        // Then should match expected case
        expect(error) == .licenseExpired
    }

    // MARK: - Error Description Tests (LocalizedError)

    func testInvalidLicenseKeyDescription() {
        // Given invalid license key error
        let error = LicenseError.invalidLicenseKey

        // Then should have correct description
        expect(error.errorDescription) == "The license key provided is invalid."
    }

    func testNetworkErrorDescription() {
        // Given network error
        struct MockError: Error, LocalizedError {
            var errorDescription: String? {
                "Connection timeout"
            }
        }
        let error = LicenseError.networkError(MockError())

        // Then should include underlying error description
        expect(error.errorDescription?.contains("Network error") ?? false) == true
        expect(error.errorDescription?.contains("Connection timeout") ?? false) == true
    }

    func testValidationFailedDescription() {
        // Given validation failed error
        let error = LicenseError.validationFailed

        // Then should have correct description
        expect(error.errorDescription) == "License validation failed."
    }

    func testTrialAlreadyStartedDescription() {
        // Given trial already started error
        let error = LicenseError.trialAlreadyStarted

        // Then should have correct description
        expect(error.errorDescription) == "Trial period has already been started."
    }

    func testTrialAlreadyUsedDescription() {
        // Given trial already used error
        let error = LicenseError.trialAlreadyUsed

        // Then should have correct description
        expect(error.errorDescription) ==
            "Trial has already been used on this device. Please purchase a license to continue using the app."
    }

    func testLicenseExpiredDescription() {
        // Given license expired error
        let error = LicenseError.licenseExpired

        // Then should have correct description
        expect(error.errorDescription) == "License is expired or inactive."
    }

    // MARK: - Pattern Matching Tests

    func testPatternMatchingForInvalidLicenseKey() {
        // Given invalid license key error
        let error = LicenseError.invalidLicenseKey

        // When pattern matching
        switch error {
        case .invalidLicenseKey:
            // Then should match
            break

        default:
            XCTFail("Should match invalidLicenseKey case")
        }
    }

    func testPatternMatchingForNetworkError() {
        // Given network error
        struct MockError: Error { }
        let error = LicenseError.networkError(MockError())

        // When pattern matching with value extraction
        switch error {
        case let .networkError(underlyingError):
            // Then should match and extract error
            expect(underlyingError is MockError) == true

        default:
            XCTFail("Should match networkError case")
        }
    }

    func testPatternMatchingForValidationFailed() {
        // Given validation failed error
        let error = LicenseError.validationFailed

        // When pattern matching
        switch error {
        case .validationFailed:
            // Then should match
            break

        default:
            XCTFail("Should match validationFailed case")
        }
    }

    func testPatternMatchingForTrialErrors() {
        // Given trial errors
        let errors: [LicenseError] = [
            .trialAlreadyStarted,
            .trialAlreadyUsed
        ]

        // When checking trial-related errors
        for error in errors {
            switch error {
            case .trialAlreadyStarted,
                 .trialAlreadyUsed:
                // Then should match trial cases
                break

            default:
                XCTFail("Should match trial case")
            }
        }
    }

    // MARK: - Error Throwing Tests

    func testThrowingLicenseError() throws {
        /// Given a function that throws LicenseError
        func throwError() throws {
            throw LicenseError.invalidLicenseKey
        }

        // When catching the error
        do {
            try throwError()
            XCTFail("Should have thrown error")
        } catch let error as LicenseError {
            // Then should catch as LicenseError
            expect(error) == .invalidLicenseKey
        } catch {
            XCTFail("Should catch as LicenseError, not generic Error")
        }
    }

    func testThrowingNetworkError() {
        /// Given a function that throws network error
        func throwError() throws {
            struct NetworkFailure: Error { }
            throw LicenseError.networkError(NetworkFailure())
        }

        // When/Then catching the error
        do {
            try throwError()
            XCTFail("Should have thrown error")
        } catch let error as LicenseError {
            if case .networkError = error {
                // Success - correct error type
            } else {
                XCTFail("Should be networkError case")
            }
        } catch {
            XCTFail("Should throw LicenseError")
        }
    }

    // MARK: - LocalizedError Protocol Conformance

    func testConformsToLocalizedError() {
        // Given any LicenseError
        let error: Error = LicenseError.invalidLicenseKey

        // Then should be usable as LocalizedError
        if let localizedError = error as? LocalizedError {
            expect(localizedError.errorDescription).toNot(beNil())
        } else {
            XCTFail("LicenseError should conform to LocalizedError")
        }
    }

    func testAllErrorsHaveDescriptions() {
        // Given all error cases
        let errors: [LicenseError] = [
            .invalidLicenseKey,
            .networkError(NSError(domain: "test", code: -1)),
            .validationFailed,
            .trialAlreadyStarted,
            .trialAlreadyUsed,
            .licenseExpired
        ]

        // Then all should have non-nil error descriptions
        for error in errors {
            expect(error.errorDescription).toNot(beNil())
        }
    }

    // MARK: - Integration Tests

    func testUsingInResultType() {
        // Given a Result with LicenseError as failure type
        let successResult: Result<String, LicenseError> = .success("data")
        let failureResult: Result<String, LicenseError> = .failure(.invalidLicenseKey)

        // Then should work correctly with Result
        expect { try successResult.get() }.toNot(throwError())
        expect { try failureResult.get() }.to(throwError(LicenseError.invalidLicenseKey))
    }

    func testUsingInAsyncThrows() {
        /// Given an async function that throws LicenseError
        func asyncThrowingFunction() throws -> String {
            throw LicenseError.validationFailed
        }

        // Then should be catchable in async context
        do {
            _ = try asyncThrowingFunction()
            XCTFail("Should have thrown error")
        } catch let error as LicenseError {
            expect(error) == .validationFailed
        } catch {
            XCTFail("Should catch as LicenseError")
        }
    }

    // MARK: - Network Error Scenarios

    func testNetworkErrorWithURLError() {
        // Given URL error
        let urlError = URLError(.notConnectedToInternet)
        let error = LicenseError.networkError(urlError)

        // Then should preserve URL error information
        if case let .networkError(underlyingError) = error {
            expect(underlyingError is URLError) == true
            if let urlErr = underlyingError as? URLError {
                expect(urlErr.code) == .notConnectedToInternet
            }
        } else {
            XCTFail("Should be networkError case")
        }
    }

    func testNetworkErrorWithNSError() {
        // Given NSError
        let nsError = NSError(domain: "com.test", code: 500, userInfo: [
            NSLocalizedDescriptionKey: "Server unavailable"
        ])
        let error = LicenseError.networkError(nsError)

        // Then should preserve NSError information
        if case let .networkError(underlyingError) = error {
            let nsErr = underlyingError as NSError
            expect(nsErr.code) == 500
            expect(nsErr.domain) == "com.test"
        } else {
            XCTFail("Should be networkError case")
        }
    }

    func testNetworkErrorWithCustomError() {
        // Given custom error
        struct CustomNetworkError: Error, LocalizedError {
            let code: Int
            var errorDescription: String? {
                "Custom error: \(code)"
            }
        }

        let customError = CustomNetworkError(code: 404)
        let error = LicenseError.networkError(customError)

        // Then should wrap custom error
        if case let .networkError(underlyingError) = error {
            expect(underlyingError is CustomNetworkError) == true
            if let custom = underlyingError as? CustomNetworkError {
                expect(custom.code) == 404
            }
        } else {
            XCTFail("Should be networkError case")
        }
    }

    // MARK: - Trial Error Scenarios

    func testTrialErrorsAreDistinct() {
        // Given different trial errors
        let started = LicenseError.trialAlreadyStarted
        let used = LicenseError.trialAlreadyUsed

        // Then they should be different
        expect(started) != used
    }

    func testTrialAlreadyStartedVsTrialAlreadyUsed() {
        // trialAlreadyStarted: Trial was initiated but might be active
        // trialAlreadyUsed: Trial was consumed and is no longer valid

        let started = LicenseError.trialAlreadyStarted
        let used = LicenseError.trialAlreadyUsed

        // Then descriptions should be different
        expect(started.errorDescription) != used.errorDescription
    }

    // MARK: - Error Equality Tests

    func testEqualityForSimpleCases() {
        // Given same simple error cases
        let error1 = LicenseError.invalidLicenseKey
        let error2 = LicenseError.invalidLicenseKey

        // Then should be equal
        expect(error1) == error2
    }

    func testInequalityBetweenDifferentCases() {
        // Given different error cases
        let errors: [LicenseError] = [
            .invalidLicenseKey,
            .validationFailed,
            .trialAlreadyStarted,
            .trialAlreadyUsed,
            .licenseExpired
        ]

        // Then all should be different
        for (index, error1) in errors.enumerated() {
            for (otherIndex, error2) in errors.enumerated() where otherIndex != index {
                expect(error1) != error2
            }
        }
    }

    // MARK: - Edge Cases

    func testNetworkErrorDescriptionWithEmptyError() {
        // Given error with no description
        struct EmptyError: Error { }
        let error = LicenseError.networkError(EmptyError())

        // Then should still have network error prefix
        expect(error.errorDescription?.hasPrefix("Network error") ?? false) == true
    }

    func testErrorDescriptionsNotEmpty() {
        // Given all errors
        let errors: [LicenseError] = [
            .invalidLicenseKey,
            .networkError(NSError(domain: "test", code: -1)),
            .validationFailed,
            .trialAlreadyStarted,
            .trialAlreadyUsed,
            .licenseExpired
        ]

        // Then all descriptions should be non-empty
        for error in errors {
            expect(error.errorDescription?.isEmpty ?? true) == false
        }
    }

    func testCascadingErrorHandling() {
        /// Given nested error handling
        func validateLicense() throws {
            throw LicenseError.invalidLicenseKey
        }

        func performAction() throws {
            do {
                try validateLicense()
            } catch _ as LicenseError {
                // Re-throw as different error
                throw LicenseError.validationFailed
            }
        }

        // When/Then catching cascaded error
        expect { try performAction() }.to(throwError(LicenseError.validationFailed))
    }
}
