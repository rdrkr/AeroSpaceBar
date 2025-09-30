// Copyright (c) 2025 AeroSpaceBar by Ronen Druker.

import Domain
import SwiftUI

/// A reusable view for configuring geometric properties.
///
/// This view provides standardized controls for adjusting border width and corner radius
/// of visual elements.
struct GeometrySettingsView: View {
    /// The entity name for which this geometry setting view is for
    let entityName: String

    /// The binding to the geometric properties being edited.
    let geometricProperties: Binding<GeometricProperties>

    /// The default global geometric properties for the entity.
    let defaultGeometricProperties: GeometricProperties

    /// The main body of the geometry settings view.
    var body: some View {
        SettingsSlider(
            value: geometricProperties.borderWidth,
            in: 0.0 ... 5.0,
            defaultValue: defaultGeometricProperties.borderWidth,
            stickiness: 0.25,
            label: LocalizedStringResource("Border Width"),
            helpText: LocalizedStringResource(stringLiteral:
                "Adjust the border width of \(entityName.lowercased()) elements."
            ),
            displayAsPoints: true
        )
        .tag("\(entityName.lowercased())-border-width")

        SettingsSlider(
            value: geometricProperties.cornerRadius,
            in: 0.0 ... defaultGeometricProperties.cornerRadius,
            defaultValue: defaultGeometricProperties.cornerRadius,
            stickiness: 1.0,
            label: LocalizedStringResource("Corner Radius"),
            helpText: LocalizedStringResource(stringLiteral:
                "Adjust the corner radius of \(entityName.lowercased()) elements."
            ),
            displayAsPoints: true
        )
        .tag("\(entityName.lowercased())-corner-radius")
    }
}
