// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

/// Use case for setting spaces geometric properties configuration.
///
/// This use case handles updating the geometric properties for individual spaces,
/// allowing for space-specific geometry customization. Changes are persisted
/// through the ConfigurationGateway.
@MainActor
public final class SetSpacesGeometricPropertiesUseCase {
    /// The configuration gateway to update spaces geometric properties through.
    private let configurationGateway: ConfigurationGateway

    /// Initializes a new instance of the use case.
    ///
    /// - Parameter configurationGateway: The gateway to use for updating spaces geometric properties
    public init(configurationGateway: ConfigurationGateway) {
        self.configurationGateway = configurationGateway
    }

    /// Executes the use case to set the spaces geometric properties.
    ///
    /// - Parameter value: The array of geometric properties to set for spaces
    public func execute(value: [GeometricProperties]) async {
        await configurationGateway.setSpacesGeometricProperties(value)
    }
}
