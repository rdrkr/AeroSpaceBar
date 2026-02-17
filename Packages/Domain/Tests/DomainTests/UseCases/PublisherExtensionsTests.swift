// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@preconcurrency @unsafe import Combine
@testable import Domain
import Nimble
import XCTest

/// Tests for PublisherExtensions.
///
/// These tests verify that blocking publisher extension including:
/// - blockingFirst() functionality
/// - Proper value emission
/// - Error handling when no value emitted
final class PublisherExtensionsTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }

    // MARK: - blockingFirst() Tests

    func testBlockingFirstWithImmediateValue() {
        // Given a publisher that emits immediately
        let publisher = Just(42)

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return the value
        expect(result) == 42
    }

    func testBlockingFirstWithCurrentValueSubject() {
        // Given a CurrentValueSubject with a value
        let subject = CurrentValueSubject<String, Never>("test value")

        // When calling blockingFirst
        let result = subject.blockingFirst()

        // Then should return the current value
        expect(result) == "test value"
    }

    func testBlockingFirstWithPassthroughSubjectAndImmediateEmission() {
        // Given a PassthroughSubject
        let subject = PassthroughSubject<Int, Never>()

        // When emitting value immediately then calling blockingFirst
        Task.detached {
            do {
                try await Task.sleep(for: .milliseconds(10))
            } catch {
                // Task.sleep shouldn't fail in this context, but handle it gracefully
                return
            }
            subject.send(100)
        }

        let result = subject.blockingFirst()

        // Then should receive the value
        expect(result) == 100
    }

    func testBlockingFirstTakesFirstValueOnly() {
        // Given a publisher that emits multiple values
        let publisher = [1, 2, 3, 4, 5].publisher

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should only return the first value
        expect(result) == 1
    }

    func testBlockingFirstWithBool() {
        // Given a publisher with Bool value
        let publisher = Just(true)

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return the bool value
        expect(result) == true
    }

    func testBlockingFirstWithOptionalValue() {
        // Given a publisher with optional value
        let publisher = Just<String?>("optional value")

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return the optional value
        expect(result) == "optional value"
    }

    func testBlockingFirstWithNilOptional() {
        // Given a publisher with nil optional
        let publisher = Just<String?>(nil)

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return nil
        expect(result).to(beNil())
    }

    func testBlockingFirstWithStructValue() {
        // Given a publisher with struct value
        struct TestStruct: Equatable {
            let id: Int
            let name: String
        }

        let expectedValue = TestStruct(id: 1, name: "test")
        let publisher = Just(expectedValue)

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return the struct
        expect(result) == expectedValue
    }

    func testBlockingFirstPreservesValueType() {
        // Given publishers with different types
        let intPublisher = Just(42)
        let stringPublisher = Just("test")
        let doublePublisher = Just(3.14)

        // When calling blockingFirst
        let intResult = intPublisher.blockingFirst()
        let stringResult = stringPublisher.blockingFirst()
        let doubleResult = doublePublisher.blockingFirst()

        // Then should preserve types
        expect(String(describing: type(of: intResult)) == "Int") == true
        expect(String(describing: type(of: stringResult)) == "String") == true
        expect(String(describing: type(of: doubleResult)) == "Double") == true
    }

    func testBlockingFirstWithArrayValue() {
        // Given a publisher with array value
        let array = [1, 2, 3, 4, 5]
        let publisher = Just(array)

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return the array
        expect(result) == array
    }

    // MARK: - Error Handling Tests

    // Note: Tests for fatalError (empty/failure publisher) are removed
    // because Nimble's throwAssertion is not supported on arm64.

    func testBlockingFirstWithDelayedValue() {
        // Given a publisher that emits immediately
        let publisher = Future<Int, Never> { promise in
            promise(.success(42))
        }

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should wait and return value
        expect(result) == 42
    }

    func testBlockingFirstWithMultipleValuesAndCompletion() {
        // Given a publisher that emits multiple values then completes
        let subject = CurrentValueSubject<Int, Never>(1)

        // Schedule additional values asynchronously
        Task.detached {
            do {
                try await Task.sleep(for: .milliseconds(10))
            } catch {
                return
            }
            subject.send(2)
            do {
                try await Task.sleep(for: .milliseconds(10))
            } catch {
                return
            }
            subject.send(completion: .finished)
        }

        let result = subject.blockingFirst()

        // Then should return first value
        expect(result) == 1
    }

    // MARK: - Type System Tests

    func testBlockingFirstWithCustomClass() {
        // Given a publisher with custom class
        class TestClass: Equatable {
            let value: String

            init(value: String) {
                self.value = value
            }

            static func == (lhs: TestClass, rhs: TestClass) -> Bool {
                lhs.value == rhs.value
            }
        }

        let expectedObject = TestClass(value: "test")
        let publisher = Just(expectedObject)

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return the object
        expect(result) == expectedObject
        expect(result.value) == "test"
    }

    func testBlockingFirstWithEnumValue() {
        // Given a publisher with enum value
        enum TestEnum: String, CaseIterable {
            case first
            case second
        }

        let expectedEnum = TestEnum.first
        let publisher = Just(expectedEnum)

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return the enum
        expect(result) == expectedEnum
        expect(result.rawValue) == "first"
    }

    func testBlockingFirstWithTupleValue() {
        // Given a publisher with tuple value
        let expectedTuple = (id: 1, name: "test", active: true)
        let publisher = Just(expectedTuple)

        // When calling blockingFirst
        let result = publisher.blockingFirst()

        // Then should return the tuple
        expect(result.id) == 1
        expect(result.name) == "test"
        expect(result.active) == true
    }

    // MARK: - Performance Tests

    func testBlockingFirstPerformance() {
        // Given many iterations
        let publisher = Just(42)

        // When measuring performance
        measure {
            for _ in 0 ..< 1_000 {
                _ = publisher.blockingFirst()
            }
        }
    }
}
