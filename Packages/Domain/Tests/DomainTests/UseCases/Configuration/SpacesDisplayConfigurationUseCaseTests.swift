// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

import Combine
@testable import Domain
import Foundation
import Nimble
import XCTest

@MainActor
final class SpacesDisplayConfigurationUseCaseTests: XCTestCase {
    func testDefaultsAndUpdates() async {
        let gateway = MockConfigurationGateway()
        let get = GetSpacesDisplayConfigurationUseCase(configurationGateway: gateway)
        let set = SetSpacesDisplayConfigurationUseCase(configurationGateway: gateway)
        var values: [SpacesDisplayConfiguration] = []
        let subscription = get.execute().sink { values.append($0) }
        let selected = SpacesDisplayConfiguration(mode: .selected, selectedDisplayIDs: ["disconnected-id"])

        await set.execute(value: selected)

        expect(values) == [.init(), selected]
        expect(gateway.setSpacesDisplayConfigurationCalls) == [selected]
        withExtendedLifetime(subscription) { }
    }

    func testDisplayInclusion() {
        let primary = SpacesDisplayConfiguration()
        expect(primary.includesDisplay(id: "primary", isPrimary: true)) == true
        expect(primary.includesDisplay(id: "secondary", isPrimary: false)) == false

        let all = SpacesDisplayConfiguration(mode: .all)
        expect(all.includesDisplay(id: "primary", isPrimary: true)) == true
        expect(all.includesDisplay(id: "secondary", isPrimary: false)) == true

        let selected = SpacesDisplayConfiguration(mode: .selected, selectedDisplayIDs: ["disconnected", "secondary"])
        expect(selected.includesDisplay(id: "primary", isPrimary: true)) == false
        expect(selected.includesDisplay(id: "secondary", isPrimary: false)) == true
        expect(selected.includesDisplay(id: "disconnected", isPrimary: false)) == true
        expect(selected.includesDisplay(id: "other", isPrimary: false)) == false
    }

    func testCodableRoundTrip() throws {
        let configuration = SpacesDisplayConfiguration(mode: .selected, selectedDisplayIDs: ["display-id"])
        let data = try JSONEncoder().encode(configuration)
        expect(try JSONDecoder().decode(SpacesDisplayConfiguration.self, from: data)) == configuration
    }
}
