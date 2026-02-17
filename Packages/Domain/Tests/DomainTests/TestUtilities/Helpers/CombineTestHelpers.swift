// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Nimble
import XCTest

/// Helper utilities for testing Combine publishers.
public extension XCTestCase {
    /// Awaits a publisher to emit a value and returns it.
    /// - Parameters:
    ///   - publisher: The publisher to await
    ///   - timeout: Maximum time to wait for a value (default: 1 second)
    ///   - file: The file where the assertion occurs (for better error reporting)
    ///   - line: The line where the assertion occurs (for better error reporting)
    /// - Returns: The first value emitted by the publisher
    /// - Throws: XCTSkip if no value is received within the timeout
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws -> T.Output where T.Failure == Never {
        var cancellables = Set<AnyCancellable>()
        var receivedValue: T.Output?

        let expectation = expectation(description: "Await publisher value")

        publisher
            .first()
            .sink { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: timeout)

        guard let value = receivedValue else {
            XCTFail("Publisher did not emit a value within timeout", file: file, line: line)
            throw XCTSkip("Publisher timeout")
        }

        return value
    }

    /// Collects all values emitted by a publisher within a time window.
    /// - Parameters:
    ///   - publisher: The publisher to collect from
    ///   - timeout: Time window to collect values (default: 0.1 seconds)
    /// - Returns: Array of all values emitted during the time window
    func collectPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 0.1
    ) async -> [T.Output] where T.Failure == Never {
        var cancellables = Set<AnyCancellable>()
        var collectedValues: [T.Output] = []

        publisher
            .sink { value in
                collectedValues.append(value)
            }
            .store(in: &cancellables)

        // Wait for the timeout period to collect values
        try? await Task.sleep(for: .seconds(timeout))

        return collectedValues
    }

    /// Asserts that a publisher emits a specific value.
    /// - Parameters:
    ///   - publisher: The publisher to test
    ///   - expectedValue: The expected value
    ///   - timeout: Maximum time to wait (default: 1 second)
    ///   - file: The file where the assertion occurs
    ///   - line: The line where the assertion occurs
    func assertPublisherEmits<T: Publisher>(
        _ publisher: T,
        _ expectedValue: T.Output,
        timeout: TimeInterval = 1.0,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async where T.Output: Equatable, T.Failure == Never {
        do {
            let value = try await awaitPublisher(publisher, timeout: timeout, file: file, line: line)
            expect(value) == expectedValue
        } catch {
            XCTFail("Failed to receive value from publisher", file: file, line: line)
        }
    }

    /// Asserts that a publisher eventually emits a value satisfying a condition.
    /// - Parameters:
    ///   - publisher: The publisher to test
    ///   - timeout: Maximum time to wait (default: 1 second)
    ///   - condition: Predicate to test the emitted value
    ///   - file: The file where the assertion occurs
    ///   - line: The line where the assertion occurs
    func assertPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 1.0,
        satisfies condition: @escaping (T.Output) -> Bool,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) async where T.Failure == Never {
        var cancellables = Set<AnyCancellable>()
        var satisfied = false

        let expectation = expectation(description: "Publisher satisfies condition")

        publisher
            .first(where: condition)
            .sink { _ in
                satisfied = true
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: timeout)

        expect(satisfied) == true
    }
}
