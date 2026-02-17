// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

final class AppErrorTests: XCTestCase {
    // MARK: - Case Tests

    func testAeroSpaceNotRunningCase() {
        // Given aeroSpaceNotRunning error
        let error = AppError.aeroSpaceNotRunning

        // Then should match expected case
        expect(error) == .aeroSpaceNotRunning
    }

    func testCommandExecutionErrorCase() {
        // Given commandExecutionError with message
        let error = AppError.commandExecutionError("Failed to execute")

        // Then should match expected case with message
        if case let .commandExecutionError(message) = error {
            expect(message) == "Failed to execute"
        } else {
            XCTFail("Expected commandExecutionError case")
        }
    }

    func testDataFetchErrorCase() {
        // Given dataFetchError with message
        let error = AppError.dataFetchError("Network timeout")

        // Then should match expected case with message
        if case let .dataFetchError(message) = error {
            expect(message) == "Network timeout"
        } else {
            XCTFail("Expected dataFetchError case")
        }
    }

    func testDecodingErrorCase() {
        // Given decodingError with message
        let error = AppError.decodingError("Invalid JSON format")

        // Then should match expected case with message
        if case let .decodingError(message) = error {
            expect(message) == "Invalid JSON format"
        } else {
            XCTFail("Expected decodingError case")
        }
    }

    func testServiceUnavailableCase() {
        // Given serviceUnavailable error
        let error = AppError.serviceUnavailable

        // Then should match expected case
        expect(error) == .serviceUnavailable
    }

    // MARK: - Equality Tests

    func testEqualityForAeroSpaceNotRunning() {
        // Given two aeroSpaceNotRunning errors
        let error1 = AppError.aeroSpaceNotRunning
        let error2 = AppError.aeroSpaceNotRunning

        // Then they should be equal
        expect(error1) == error2
    }

    func testEqualityForCommandExecutionErrorWithSameMessage() {
        // Given two commandExecutionError with same message
        let error1 = AppError.commandExecutionError("same message")
        let error2 = AppError.commandExecutionError("same message")

        // Then they should be equal
        expect(error1) == error2
    }

    func testInequalityForCommandExecutionErrorWithDifferentMessages() {
        // Given two commandExecutionError with different messages
        let error1 = AppError.commandExecutionError("message 1")
        let error2 = AppError.commandExecutionError("message 2")

        // Then they should not be equal
        expect(error1) != error2
    }

    func testInequalityForDataFetchErrorWithDifferentMessages() {
        // Given two dataFetchError with different messages
        let error1 = AppError.dataFetchError("error 1")
        let error2 = AppError.dataFetchError("error 2")

        // Then they should not be equal
        expect(error1) != error2
    }

    func testInequalityBetweenDifferentCases() {
        // Given different error cases
        let aeroSpaceNotRunning = AppError.aeroSpaceNotRunning
        let commandError = AppError.commandExecutionError("test")
        let dataFetchError = AppError.dataFetchError("test")
        let decodingError = AppError.decodingError("test")
        let serviceUnavailable = AppError.serviceUnavailable

        // Then they should all be different
        expect(aeroSpaceNotRunning) != commandError
        expect(aeroSpaceNotRunning) != dataFetchError
        expect(aeroSpaceNotRunning) != decodingError
        expect(aeroSpaceNotRunning) != serviceUnavailable
        expect(commandError) != dataFetchError
        expect(commandError) != decodingError
        expect(commandError) != serviceUnavailable
        expect(dataFetchError) != decodingError
        expect(dataFetchError) != serviceUnavailable
        expect(decodingError) != serviceUnavailable
    }

    // MARK: - Error Description Tests (LocalizedError)

    func testAeroSpaceNotRunningDescription() {
        // Given aeroSpaceNotRunning error
        let error = AppError.aeroSpaceNotRunning

        // Then should have correct description
        expect(error.errorDescription) == "AeroSpace is not running"
    }

    func testCommandExecutionErrorDescription() {
        // Given commandExecutionError with specific message
        let error = AppError.commandExecutionError("timeout occurred")

        // Then should have correct description with message
        expect(error.errorDescription) == "Command execution failed: timeout occurred"
    }

    func testDataFetchErrorDescription() {
        // Given dataFetchError with specific message
        let error = AppError.dataFetchError("connection refused")

        // Then should have correct description with message
        expect(error.errorDescription) == "Data fetch failed: connection refused"
    }

    func testDecodingErrorDescription() {
        // Given decodingError with specific message
        let error = AppError.decodingError("unexpected format")

        // Then should have correct description with message
        expect(error.errorDescription) == "Data decoding failed: unexpected format"
    }

    func testServiceUnavailableDescription() {
        // Given serviceUnavailable error
        let error = AppError.serviceUnavailable

        // Then should have correct description
        expect(error.errorDescription) == "Service is unavailable"
    }

    // MARK: - Pattern Matching Tests

    func testPatternMatchingForAeroSpaceNotRunning() {
        // Given aeroSpaceNotRunning error
        let error = AppError.aeroSpaceNotRunning

        // When pattern matching
        switch error {
        case .aeroSpaceNotRunning:
            // Then should match
            break

        default:
            XCTFail("Should match aeroSpaceNotRunning case")
        }
    }

    func testPatternMatchingForCommandExecutionError() {
        // Given commandExecutionError
        let error = AppError.commandExecutionError("test error")

        // When pattern matching with value extraction
        switch error {
        case let .commandExecutionError(message):
            // Then should match and extract message
            expect(message) == "test error"

        default:
            XCTFail("Should match commandExecutionError case")
        }
    }

    func testPatternMatchingForDataFetchError() {
        // Given dataFetchError
        let error = AppError.dataFetchError("network error")

        // When pattern matching with value extraction
        switch error {
        case let .dataFetchError(message):
            // Then should match and extract message
            expect(message) == "network error"

        default:
            XCTFail("Should match dataFetchError case")
        }
    }

    func testPatternMatchingForDecodingError() {
        // Given decodingError
        let error = AppError.decodingError("parse error")

        // When pattern matching with value extraction
        switch error {
        case let .decodingError(message):
            // Then should match and extract message
            expect(message) == "parse error"

        default:
            XCTFail("Should match decodingError case")
        }
    }

    // MARK: - Error Throwing Tests

    func testThrowingAppError() throws {
        /// Given a function that throws AppError
        func throwError() throws {
            throw AppError.aeroSpaceNotRunning
        }

        // When catching the error
        do {
            try throwError()
            XCTFail("Should have thrown error")
        } catch let error as AppError {
            // Then should catch as AppError
            expect(error) == .aeroSpaceNotRunning
        } catch {
            XCTFail("Should catch as AppError, not generic Error")
        }
    }

    func testThrowingAppErrorWithMessage() {
        /// Given a function that throws AppError with message
        func throwError() throws {
            throw AppError.commandExecutionError("custom error message")
        }

        // When catching the error
        do {
            _ = try throwError()
            XCTFail("Should have thrown AppError")
        } catch let error as AppError {
            // Then should be correct error with message
            if case let .commandExecutionError(message) = error {
                expect(message) == "custom error message"
            } else {
                XCTFail("Should be commandExecutionError case")
            }
        } catch {
            XCTFail("Should be AppError type")
        }
    }

    // MARK: - Edge Cases

    func testEmptyErrorMessage() {
        // Given error with empty message
        let error = AppError.commandExecutionError("")

        // Then should handle empty message
        if case let .commandExecutionError(message) = error {
            expect(message.isEmpty) == true
            expect(error.errorDescription) == "Command execution failed: "
        } else {
            XCTFail("Expected commandExecutionError case")
        }
    }

    func testVeryLongErrorMessage() {
        // Given error with very long message
        let longMessage = String(repeating: "Error ", count: 100)
        let error = AppError.dataFetchError(longMessage)

        // Then should handle long message
        if case let .dataFetchError(message) = error {
            expect(message.count) == 600 // "Error " * 100 = 600 chars
            expect(error.errorDescription?.contains(longMessage)) == true
        } else {
            XCTFail("Expected dataFetchError case")
        }
    }

    func testSpecialCharactersInErrorMessage() {
        // Given error with special characters
        let specialMessage = "Error: 🚀 Failed! @#$%^&*()"
        let error = AppError.decodingError(specialMessage)

        // Then should preserve special characters
        if case let .decodingError(message) = error {
            expect(message) == specialMessage
            expect(error.errorDescription?.contains(specialMessage) ?? false) == true
        } else {
            XCTFail("Expected decodingError case")
        }
    }

    func testMultilineErrorMessage() {
        // Given error with multiline message
        let multilineMessage = """
        Line 1
        Line 2
        Line 3
        """
        let error = AppError.commandExecutionError(multilineMessage)

        // Then should preserve multiline format
        if case let .commandExecutionError(message) = error {
            expect(message) == multilineMessage
            expect(message.contains("\n")) == true
        } else {
            XCTFail("Expected commandExecutionError case")
        }
    }

    // MARK: - LocalizedError Protocol Conformance

    func testConformsToLocalizedError() {
        // Given any AppError
        let error: Error = AppError.aeroSpaceNotRunning

        // Then should be usable as LocalizedError
        if let localizedError = error as? LocalizedError {
            expect(localizedError.errorDescription).toNot(beNil())
        } else {
            XCTFail("AppError should conform to LocalizedError")
        }
    }

    func testLocalizedErrorDescriptionNotNil() {
        // Given all error cases
        let errors: [AppError] = [
            .aeroSpaceNotRunning,
            .commandExecutionError("test"),
            .dataFetchError("test"),
            .decodingError("test"),
            .serviceUnavailable
        ]

        // Then all should have non-nil error descriptions
        for error in errors {
            expect(error.errorDescription).toNot(beNil())
        }
    }

    // MARK: - Integration Tests

    func testUsingInResultType() {
        // Given a Result with AppError as failure type
        let successResult: Result<String, AppError> = .success("data")
        let failureResult: Result<String, AppError> = .failure(.aeroSpaceNotRunning)

        // Then should work correctly with Result
        expect { try successResult.get() }.toNot(throwError())
        expect { try failureResult.get() }.to(throwError(AppError.aeroSpaceNotRunning))
    }

    func testUsingInAsyncThrows() {
        /// Given an async function that throws AppError
        func asyncThrowingFunction() throws -> String {
            throw AppError.serviceUnavailable
        }

        // Then should be catchable in async context
        do {
            _ = try asyncThrowingFunction()
            XCTFail("Should have thrown error")
        } catch let error as AppError {
            expect(error) == .serviceUnavailable
        } catch {
            XCTFail("Should catch as AppError")
        }
    }
}
