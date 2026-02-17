// Copyright (c) 2026 AeroSpaceBar by Ronen Druker.

@testable import Data
import LemonSqueezy
import XCTest

final class LemonSqueezyTypeCheckTests: XCTestCase {
    func testTypesAreDecodable() {
        let json = Data("{}".utf8)
        // Try to decode to check if they conform to Decodable
        // We expect this to fail decoding but compile if they are Decodable
        _ = try? JSONDecoder().decode(ValidateLicense.self, from: json)
        _ = try? JSONDecoder().decode(ActivateLicense.self, from: json)
    }
}
