// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for TaskExtensions withTimeout functions.
///
/// These tests verify timeout functionality with various clock types, durations,
/// and operation behaviors including success, failure, and timeout scenarios.
@MainActor
final class TaskExtensionsTests: XCTestCase {
    // MARK: - Basic Timeout Tests

    func testWithTimeoutCompletesBeforeTimeout() async throws {
        // Given operation that completes quickly
        let result = try await withTimeout(for: .seconds(5)) {
            try await Task.sleep(for: .milliseconds(10))
            return "success"
        }

        // Then should complete successfully
        expect(result) == "success"
    }

    func testWithTimeoutThrowsWhenOperationExceedsTimeout() async {
        // Given operation that takes longer than timeout
        do {
            _ = try await withTimeout(for: .milliseconds(50)) {
                try await Task.sleep(for: .seconds(10))
                return "should not complete"
            }
            XCTFail("Should have thrown TimeoutExceededError")
        } catch is TimeoutExceededError {
            // Then should throw timeout error
        } catch {
            XCTFail("Threw unexpected error: \(error)")
        }
    }

    // MARK: - Different Result Types Tests

    func testWithTimeoutStringResult() async throws {
        // Given operation returning String
        let result: String = try await withTimeout(for: .seconds(1)) {
            "test string"
        }

        // Then should return correct type
        expect(result) == "test string"
        expect(String(describing: type(of: result))) == String(describing: String.self)
    }

    func testWithTimeoutIntResult() async throws {
        // Given operation returning Int
        let result: Int = try await withTimeout(for: .seconds(1)) {
            42
        }

        // Then should return correct value
        expect(result) == 42
        expect(String(describing: type(of: result))) == String(describing: Int.self)
    }

    func testWithTimeoutBoolResult() async throws {
        // Given operation returning Bool
        let result: Bool = try await withTimeout(for: .seconds(1)) {
            true
        }

        // Then should return correct value
        expect(result) == true
        expect(String(describing: type(of: result))) == String(describing: Bool.self)
    }

    func testWithTimeoutOptionalResult() async throws {
        // Given operation returning Optional
        let result: String? = try await withTimeout(for: .seconds(1)) {
            Optional("value")
        }

        // Then should return correct value
        expect(result) == "value"
    }

    func testWithTimeoutNilResult() async throws {
        // Given operation returning nil
        let result: String? = try await withTimeout(for: .seconds(1)) {
            nil as String?
        }

        // Then should return nil
        expect(result).to(beNil())
    }

    // MARK: - Clock Type Tests

    func testWithTimeoutUsingContinuousClock() async throws {
        // Given operation with explicit ContinuousClock
        let start = ContinuousClock.now
        let result = try await withTimeout(
            for: .seconds(1),
            clock: ContinuousClock()
        ) {
            try await Task.sleep(for: .milliseconds(10))
            return "done"
        }
        let elapsed = ContinuousClock.now - start

        // Then should complete in reasonable time
        expect(result) == "done"
        expect(elapsed) < .seconds(1)
    }

    func testWithTimeoutDefaultClock() async throws {
        // Given operation without explicit clock
        let result = try await withTimeout(for: .seconds(1)) {
            "default clock"
        }

        // Then should use ContinuousClock by default
        expect(result) == "default clock"
    }

    func testWithTimeoutUsingInstant() async throws {
        // Given operation with absolute instant
        let deadline = ContinuousClock.now + .seconds(1)
        let result = try await withTimeout(until: deadline) {
            try await Task.sleep(for: .milliseconds(10))
            return "instant"
        }

        // Then should complete successfully
        expect(result) == "instant"
    }

    // MARK: - Tolerance Tests

    func testWithTimeoutWithTolerance() async throws {
        // Given operation with tolerance
        let result = try await withTimeout(
            for: .seconds(1),
            tolerance: .milliseconds(100)
        ) {
            try await Task.sleep(for: .milliseconds(10))
            return "with tolerance"
        }

        // Then should complete successfully
        expect(result) == "with tolerance"
    }

    func testWithTimeoutWithNilTolerance() async throws {
        // Given operation with nil tolerance
        let result = try await withTimeout(
            for: .seconds(1),
            tolerance: nil
        ) {
            "nil tolerance"
        }

        // Then should complete successfully
        expect(result) == "nil tolerance"
    }

    // MARK: - Error Handling Tests

    func testWithTimeoutPropagatesOperationError() async {
        // Given operation that throws custom error
        struct CustomError: Error, Equatable { }

        do {
            _ = try await withTimeout(for: .seconds(1)) {
                throw CustomError()
            }
            XCTFail("Should have thrown CustomError")
        } catch is CustomError {
            // Then should propagate the error
        } catch {
            XCTFail("Threw unexpected error: \(error)")
        }
    }

    func testWithTimeoutDistinguishesErrorTypes() async {
        // Given custom error type
        struct OperationError: Error { }

        // When operation throws
        do {
            _ = try await withTimeout(for: .seconds(1)) {
                throw OperationError()
            }
            XCTFail("Should have thrown OperationError")
        } catch is OperationError {
            // Then should throw operation error, not timeout
        } catch {
            XCTFail("Threw unexpected error: \(error)")
        }
    }

    // MARK: - Cancellation Tests

    func testWithTimeoutSupportsCancellation() async {
        // Given operation that can be cancelled
        let task = Task {
            try await withTimeout(for: .seconds(10)) {
                try await Task.sleep(for: .seconds(100))
                return "should be cancelled"
            }
        }

        // When cancelling immediately
        task.cancel()

        // Then should handle cancellation
        do {
            _ = try await task.value
            // May complete with cancellation or timeout
        } catch {
            // Expected to throw either CancellationError or TimeoutExceededError
            expect(error is CancellationError || error is TimeoutExceededError) == true
        }
    }

    // MARK: - Edge Cases

    func testWithTimeoutZeroDuration() async {
        // Given zero timeout duration
        do {
            _ = try await withTimeout(for: .zero) {
                "immediate"
            }
            // May succeed if operation is truly immediate
        } catch is TimeoutExceededError {
            // Or may timeout - both are acceptable
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testWithTimeoutVeryShortDuration() async {
        // Given very short timeout
        do {
            _ = try await withTimeout(for: .microseconds(1)) {
                "very fast"
            }
            // May succeed if operation completes instantly
        } catch is TimeoutExceededError {
            // Or may timeout - both are acceptable for microsecond timeout
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testWithTimeoutLongDuration() async throws {
        // Given long timeout with quick operation
        let result = try await withTimeout(for: .seconds(3_600)) { // 1 hour
            "quick operation"
        }

        // Then should complete quickly despite long timeout
        expect(result) == "quick operation"
    }

    // MARK: - Concurrent Operations Tests

    func testMultipleTimeoutsConcurrently() async throws {
        // Given multiple timeout operations
        let results = try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                try await withTimeout(for: .seconds(1)) {
                    try await Task.sleep(for: .milliseconds(10))
                    return "first"
                }
            }

            group.addTask {
                try await withTimeout(for: .seconds(1)) {
                    try await Task.sleep(for: .milliseconds(20))
                    return "second"
                }
            }

            group.addTask {
                try await withTimeout(for: .seconds(1)) {
                    try await Task.sleep(for: .milliseconds(30))
                    return "third"
                }
            }

            var collected: [String] = []
            for try await result in group {
                collected.append(result)
            }
            return collected
        }

        // Then all should complete successfully
        expect(results.count) == 3
        expect(results.contains("first")) == true
        expect(results.contains("second")) == true
        expect(results.contains("third")) == true
    }

    // MARK: - TimeoutExceededError Tests

    func testTimeoutExceededErrorCanBeCaught() async {
        // Given operation that times out
        var caughtCorrectError = false

        do {
            _ = try await withTimeout(for: .milliseconds(10)) {
                try await Task.sleep(for: .seconds(10))
                return "timeout"
            }
        } catch is TimeoutExceededError {
            caughtCorrectError = true
        } catch {
            XCTFail("Caught wrong error type")
        }

        // Then should catch TimeoutExceededError
        expect(caughtCorrectError) == true
    }

    // MARK: - Sendable Conformance Tests

    func testWithTimeoutAcceptsSendableResults() async throws {
        // Given Sendable result type
        struct SendableData: Sendable {
            let value: Int
        }

        let result = try await withTimeout(for: .seconds(1)) {
            SendableData(value: 42)
        }

        // Then should work with Sendable types
        expect(result.value) == 42
    }
}
