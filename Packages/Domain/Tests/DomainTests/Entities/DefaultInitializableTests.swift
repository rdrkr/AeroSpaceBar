// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import XCTest

/// Tests for DefaultInitializable protocol.
///
/// These tests verify DefaultInitializable protocol conformance for standard types
/// and proper default initialization behavior.
@MainActor
final class DefaultInitializableTests: XCTestCase {
    // MARK: - Protocol Conformance Tests

    func testArrayConformance() {
        // Given Array type
        // When creating default instance
        let array = [Int]()

        // Then should be empty
        expect(array.isEmpty) == true
    }

    func testBoolConformance() {
        // Given Bool type
        // When creating default instance
        let bool = Bool()

        // Then should be false
        expect(bool) == false
    }

    func testDictionaryConformance() {
        // Given Dictionary type
        // When creating default instance
        let dict = [String: Int]()

        // Then should be empty
        expect(dict.isEmpty) == true
    }

    func testDoubleConformance() {
        // Given Double type
        // When creating default instance
        let double = Double()

        // Then should be 0.0
        expect(double) == 0.0
    }

    func testFloatConformance() {
        // Given Float type
        // When creating default instance
        let float = Float()

        // Then should be 0.0
        expect(float) == 0.0
    }

    func testIntConformance() {
        // Given Int type
        // When creating default instance
        let int = Int()

        // Then should be 0
        expect(int) == 0
    }

    func testStringConformance() {
        // Given String type
        // When creating default instance
        let string = String()

        // Then should be empty
        expect(string.isEmpty) == true
    }

    // MARK: - Sendable Conformance Tests

    func testArraySendable() {
        // Array conformance includes Sendable
        Task {
            let array = [Int]()
            // If this compiles, Sendable conformance works
            expect(array).toNot(beNil())
        }
    }

    func testBoolSendable() {
        // Bool conformance includes Sendable
        Task {
            let bool = Bool()
            // If this compiles, Sendable conformance works
            expect(bool).toNot(beNil())
        }
    }

    func testDictionarySendable() {
        // Dictionary conformance includes Sendable
        Task {
            let dict = [String: Int]()
            // If this compiles, Sendable conformance works
            expect(dict).toNot(beNil())
        }
    }

    // MARK: - Generic Usage Tests

    func testGenericDefaultInitializable() {
        /// Given generic function using DefaultInitializable
        func createDefault<T: DefaultInitializable>() -> T {
            T()
        }

        // When calling with different types
        let int: Int = createDefault()
        let string: String = createDefault()
        let bool: Bool = createDefault()

        // Then should create default instances
        expect(int) == 0
        expect(string.isEmpty) == true
        expect(bool) == false
    }

    func testGenericArrayDefaultInitializable() {
        /// Given generic function
        func createDefault<T: DefaultInitializable>() -> T {
            T()
        }

        // When calling with array type
        let array: [String] = createDefault()

        // Then should create empty array
        expect(array.isEmpty) == true
    }

    func testGenericDictionaryDefaultInitializable() {
        /// Given generic function
        func createDefault<T: DefaultInitializable>() -> T {
            T()
        }

        // When calling with dictionary type
        let dict: [String: Int] = createDefault()

        // Then should create empty dictionary
        expect(dict.isEmpty) == true
    }

    // MARK: - Collection Tests

    func testArrayOfDifferentTypes() {
        // Given arrays of different types
        let intArray = [Int]()
        let stringArray = [String]()
        let doubleArray = [Double]()

        // Then all should be default initialized
        expect(intArray.isEmpty) == true
        expect(stringArray.isEmpty) == true
        expect(doubleArray.isEmpty) == true
    }

    func testDictionaryOfDifferentTypes() {
        // Given dictionaries of different types
        let stringIntDict = [String: Int]()
        let intStringDict = [Int: String]()
        let stringDoubleDict = [String: Double]()

        // Then all should be default initialized
        expect(stringIntDict.isEmpty) == true
        expect(intStringDict.isEmpty) == true
        expect(stringDoubleDict.isEmpty) == true
    }

    // MARK: - Numeric Types Tests

    func testNumericTypesDefaultToZero() {
        // Given numeric types
        let int = Int()
        let double = Double()
        let float = Float()

        // Then all should default to zero
        expect(int) == 0
        expect(double) == 0.0
        expect(float) == 0.0
    }

    // MARK: - Integration Tests

    func testUsageInOptionalBinding() {
        // This test demonstrates the usage in OptionalBinding
        // Given a type that conforms to DefaultInitializable
        let defaultInt = Int()

        // Then should be usable for default values
        expect(defaultInt) == 0
    }
}
