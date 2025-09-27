// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import SwiftUI

/// A property wrapper that handles optional bindings, allowing views to distinguish
/// between nil, true, and false states while providing convenient binding access.
///
/// This wrapper is particularly useful for optional feature toggles where you need to:
/// - Track whether a feature binding was provided (nil vs non-nil)
/// - Access the actual boolean value when the binding exists
/// - Provide a binding for UI controls like Toggle
///
/// ```
/// struct MyView: View {
///     @OptionalBinding var isFeatureEnabled: Bool?
///
///     init(isFeatureEnabled: Binding<Bool>? = nil) {
///         _isFeatureEnabled = OptionalBinding(isFeatureEnabled)
///     }
///
///     var body: some View {
///         if isFeatureEnabled != nil {
///             Toggle("Feature", isOn: $isFeatureEnabled.wrappedValue)
///         }
///     }
/// }
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct OptionalBinding<T>: DynamicProperty {
    // MARK: - Storage

    /// The optional binding provided by the parent view.
    private let externalBinding: Binding<T>?

    /// Local state used when no external binding is supplied.
    @State private var localValue: T

    // MARK: - Value access

    /// Returns the optional value - nil if no binding was provided, otherwise the binding's value.
    public var wrappedValue: T? {
        get {
            externalBinding?.wrappedValue
        }
        nonmutating set {
            if let newValue {
                externalBinding?.wrappedValue = newValue
            }
        }
    }

    /// Provides a binding to the non-optional value for use with UI controls.
    /// This should only be used when you've confirmed that wrappedValue is not nil.
    public var projectedValue: Binding<T> {
        if let binding = externalBinding {
            binding
        } else {
            $localValue
        }
    }

    // MARK: - Initializers

    /// Creates an instance backed by the given optional binding.
    ///
    /// - Parameter optionalBinding: A `Binding<T>` or `nil`.
    public init(_ optionalBinding: Binding<T>?) where T: DefaultInitializable {
        externalBinding = optionalBinding
        _localValue = State(initialValue: T())
    }

    /// Creates an instance backed by the given optional binding with a default value.
    ///
    /// - Parameters:
    ///   - optionalBinding: A `Binding<T>` or `nil`.
    ///   - defaultValue: The default value to use for local state.
    public init(_ optionalBinding: Binding<T>?, defaultValue: T) {
        externalBinding = optionalBinding
        _localValue = State(initialValue: defaultValue)
    }
}
