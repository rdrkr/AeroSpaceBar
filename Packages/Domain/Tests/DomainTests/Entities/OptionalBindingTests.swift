// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
import Domain
import Nimble
import SwiftUI
import XCTest

/// Tests for OptionalBinding property wrapper.
///
/// These tests verify the property wrapper's handling of optional bindings,
/// including nil/non-nil state tracking, value access, and SwiftUI integration.
@MainActor
final class OptionalBindingTests: XCTestCase {
    // MARK: - Initialization Tests

    func testInitWithNilBinding() {
        // Given nil binding with DefaultInitializable type
        let wrapper = OptionalBinding<Bool>(nil)

        // Then wrapped value should be nil
        expect(wrapper.wrappedValue).to(beNil())
    }

    func testInitWithNonNilBinding() {
        // Given non-nil binding using explicit OptionalBinding creation
        var source = true
        let binding = Binding(
            get: { source },
            set: { source = $0 }
        )
        let wrapper = OptionalBinding(binding)

        // Then wrapped value should match source
        expect(wrapper.wrappedValue) == true
    }

    func testInitWithDefaultValue() {
        // Given nil binding with explicit default value
        let wrapper = OptionalBinding<String>(nil, defaultValue: "default")

        // Then should use default for local state
        expect(wrapper.wrappedValue).to(beNil())
    }

    // MARK: - Wrapped Value Tests

    func testWrappedValueReturnsNilWhenNoBinding() {
        // Given wrapper without binding
        let wrapper = OptionalBinding<Int>(nil, defaultValue: 0)

        // Then wrapped value should be nil
        expect(wrapper.wrappedValue).to(beNil())
    }

    func testWrappedValueReturnsBoundValue() {
        // Given wrapper with binding using explicit Binding creation
        var source = 42
        let binding = Binding(
            get: { source },
            set: { source = $0 }
        )
        let wrapper = OptionalBinding(binding)

        // Then wrapped value should match source
        expect(wrapper.wrappedValue) == 42
    }

    func testWrappedValueSetterUpdatesBinding() {
        // Given wrapper with binding using explicit Binding creation
        var source = "initial"
        let binding = Binding(
            get: { source },
            set: { source = $0 }
        )
        let wrapper = OptionalBinding(binding)

        // When setting wrapped value
        wrapper.wrappedValue = "updated"

        // Then source should be updated
        expect(source) == "updated"
        expect(wrapper.wrappedValue) == "updated"
    }

    func testWrappedValueSetterIgnoresNil() {
        // Given wrapper with binding using explicit Binding creation
        var source = "value"
        let binding = Binding(
            get: { source },
            set: { source = $0 }
        )
        let wrapper = OptionalBinding(binding)

        // When setting nil
        wrapper.wrappedValue = nil

        // Then source should remain unchanged
        expect(source) == "value"
    }

    // MARK: - Projected Value Tests

    func testProjectedValueWithExternalBinding() {
        // Given wrapper with external binding using explicit Binding creation
        var source = 100
        let binding = Binding(
            get: { source },
            set: { source = $0 }
        )
        let wrapper = OptionalBinding(binding)

        // When accessing projected value
        let projectedBinding = wrapper.projectedValue

        // Then should return external binding
        expect(projectedBinding.wrappedValue) == 100
    }

    func testProjectedValueWithoutExternalBinding() {
        // Given wrapper without external binding
        let wrapper = OptionalBinding<Double>(nil, defaultValue: 3.14)

        // When accessing projected value
        let binding = wrapper.projectedValue

        // Then should return local state binding
        expect(binding).toNot(beNil())
    }

    func testProjectedValueCanUpdateSource() {
        // Given wrapper with binding using explicit Binding creation
        var source = false
        let binding = Binding(
            get: { source },
            set: { source = $0 }
        )
        let wrapper = OptionalBinding(binding)

        // When updating via projected value
        wrapper.projectedValue.wrappedValue = true

        // Then source should be updated
        expect(source) == true
    }

    // MARK: - DefaultInitializable Integration Tests

    func testInitWithDefaultInitializableBool() {
        // Given Bool wrapper
        let wrapper = OptionalBinding<Bool>(nil)

        // Then should use Bool default (false)
        expect(wrapper.wrappedValue).to(beNil())
        expect(wrapper.projectedValue.wrappedValue) == false
    }

    func testInitWithDefaultInitializableInt() {
        // Given Int wrapper
        let wrapper = OptionalBinding<Int>(nil)

        // Then should use Int default (0)
        expect(wrapper.wrappedValue).to(beNil())
        expect(wrapper.projectedValue.wrappedValue) == 0
    }

    func testInitWithDefaultInitializableString() {
        // Given String wrapper
        let wrapper = OptionalBinding<String>(nil)

        // Then should use String default ("")
        expect(wrapper.wrappedValue).to(beNil())
        expect(wrapper.projectedValue.wrappedValue.isEmpty) == true
    }

    func testInitWithDefaultInitializableDouble() {
        // Given Double wrapper
        let wrapper = OptionalBinding<Double>(nil)

        // Then should use Double default (0.0)
        expect(wrapper.wrappedValue).to(beNil())
        expect(wrapper.projectedValue.wrappedValue) == 0.0
    }

    func testInitWithDefaultInitializableArray() {
        // Given Array wrapper
        let wrapper = OptionalBinding<[Int]>(nil)

        // Then should use Array default ([])
        expect(wrapper.wrappedValue).to(beNil())
        expect(wrapper.projectedValue.wrappedValue.isEmpty) == true
    }

    // MARK: - Custom Default Value Tests

    func testCustomDefaultValueBool() {
        // Given wrapper with custom default
        let wrapper = OptionalBinding<Bool>(nil, defaultValue: true)

        // Then should use custom default
        expect(wrapper.wrappedValue).to(beNil())
        expect(wrapper.projectedValue.wrappedValue) == true
    }

    func testCustomDefaultValueString() {
        // Given wrapper with custom default
        let wrapper = OptionalBinding<String>(nil, defaultValue: "custom")

        // Then should use custom default
        expect(wrapper.wrappedValue).to(beNil())
        expect(wrapper.projectedValue.wrappedValue) == "custom"
    }

    func testCustomDefaultValueInt() {
        // Given wrapper with custom default
        let wrapper = OptionalBinding<Int>(nil, defaultValue: 999)

        // Then should use custom default
        expect(wrapper.wrappedValue).to(beNil())
        expect(wrapper.projectedValue.wrappedValue) == 999
    }

    // MARK: - State Distinction Tests

    func testDistinguishNilFromFalse() {
        // Given wrapper for Bool
        var source = false
        let nilWrapper = OptionalBinding<Bool>(nil)
        let falseWrapper = OptionalBinding(Binding(
            get: { source },
            set: { source = $0 }
        ))

        // Then should distinguish nil from false
        expect(nilWrapper.wrappedValue).to(beNil())
        expect(falseWrapper.wrappedValue) == false
        expect(nilWrapper.wrappedValue != falseWrapper.wrappedValue) == true
    }

    func testDistinguishNilFromTrue() {
        // Given wrapper for Bool
        var source = true
        let nilWrapper = OptionalBinding<Bool>(nil)
        let trueWrapper = OptionalBinding(Binding(
            get: { source },
            set: { source = $0 }
        ))

        // Then should distinguish nil from true
        expect(nilWrapper.wrappedValue).to(beNil())
        expect(trueWrapper.wrappedValue) == true
        expect(nilWrapper.wrappedValue != trueWrapper.wrappedValue) == true
    }

    // MARK: - Multiple Instance Tests

    func testMultipleInstancesIndependent() {
        // Given multiple wrappers
        var source1 = "first"
        var source2 = "second"
        let wrapper1 = OptionalBinding(Binding(
            get: { source1 },
            set: { source1 = $0 }
        ))
        let wrapper2 = OptionalBinding(Binding(
            get: { source2 },
            set: { source2 = $0 }
        ))

        // Then should be independent
        expect(wrapper1.wrappedValue) == "first"
        expect(wrapper2.wrappedValue) == "second"
    }

    func testMultipleInstancesCanShareSource() {
        // Given multiple wrappers sharing source
        var shared = 42
        let sharedBinding = Binding(
            get: { shared },
            set: { shared = $0 }
        )
        let wrapper1 = OptionalBinding(sharedBinding)
        let wrapper2 = OptionalBinding(sharedBinding)

        // Then should both reflect source
        expect(wrapper1.wrappedValue) == 42
        expect(wrapper2.wrappedValue) == 42
    }

    // MARK: - Type Safety Tests

    func testTypePreservation() {
        // Given wrappers of different types
        var intSource = 42
        var stringSource = "test"
        var boolSource = true

        let intBinding = Binding(get: { intSource }, set: { intSource = $0 })
        let stringBinding = Binding(get: { stringSource }, set: { stringSource = $0 })
        let boolBinding = Binding(get: { boolSource }, set: { boolSource = $0 })

        let intWrapper = OptionalBinding(intBinding)
        let stringWrapper = OptionalBinding(stringBinding)
        let boolWrapper = OptionalBinding(boolBinding)

        // Then types should be preserved
        expect(type(of: intWrapper.wrappedValue) == Int?.self) == true
        expect(type(of: stringWrapper.wrappedValue) == String?.self) == true
        expect(type(of: boolWrapper.wrappedValue) == Bool?.self) == true
    }

    // MARK: - DynamicProperty Conformance Tests

    func testDynamicPropertyConformance() {
        /// Given OptionalBinding
        /// Then should conform to DynamicProperty
        func requiresDynamicProperty(_: (some DynamicProperty).Type) { }
        requiresDynamicProperty(OptionalBinding<Bool>.self)
    }

    // MARK: - Practical Usage Scenarios

    func testFeatureToggleScenario() {
        // Given optional feature flag binding
        var featureEnabled = true
        let wrapper = OptionalBinding<Bool>(Binding(
            get: { featureEnabled },
            set: { featureEnabled = $0 }
        ))

        // When feature is bound
        // Then can check if feature exists and access value
        expect(wrapper.wrappedValue).toNot(beNil())
        expect(wrapper.wrappedValue) == true
    }

    func testUnboundFeatureScenario() {
        // Given unbound feature (no external control)
        let wrapper = OptionalBinding<Bool>(nil)

        // Then wrapped value is nil
        expect(wrapper.wrappedValue).to(beNil())

        // But projected value can still be used for local state
        expect(wrapper.projectedValue.wrappedValue) == false
    }

    func testConditionalUIScenario() {
        // Given wrapper for optional setting
        var customValue: String? = "custom"
        let withValue = OptionalBinding<String>(Binding(
            get: { customValue ?? "" },
            set: { customValue = $0 }
        ))
        let withoutValue = OptionalBinding<String>(nil)

        // Then can conditionally show UI based on binding presence
        expect(withValue.wrappedValue).toNot(beNil())
        expect(withoutValue.wrappedValue).to(beNil())
    }

    // MARK: - Edge Cases

    func testRapidUpdates() {
        // Given wrapper with binding
        var source = 0
        let binding = Binding(
            get: { source },
            set: { source = $0 }
        )
        let wrapper = OptionalBinding<Int>(binding)

        // When rapidly updating
        for i in 1 ... 100 {
            wrapper.wrappedValue = i
        }

        // Then should reflect final value
        expect(source) == 100
        expect(wrapper.wrappedValue) == 100
    }

    func testNilThenNonNil() {
        // Given wrapper starting with nil
        let wrapper = OptionalBinding<Int>(nil, defaultValue: 0)
        expect(wrapper.wrappedValue).to(beNil())

        // When setting non-nil value (this doesn't update external binding when nil)
        wrapper.wrappedValue = 42

        // Then still nil (no external binding to update)
        expect(wrapper.wrappedValue).to(beNil())
    }

    func testProjectedValueStability() {
        // Given wrapper
        var source = "test"
        let binding = Binding(
            get: { source },
            set: { source = $0 }
        )
        let wrapper = OptionalBinding<String>(binding)

        // When accessing projected value multiple times
        let binding1 = wrapper.projectedValue
        let binding2 = wrapper.projectedValue

        // Then should return consistent binding
        expect(binding1.wrappedValue) == binding2.wrappedValue
    }
}
