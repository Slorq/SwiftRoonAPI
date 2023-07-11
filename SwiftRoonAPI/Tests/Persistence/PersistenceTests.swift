//
//  PersistenceTests.swift
//  
//
//  Created by Alejandro Maya on 8/07/23.
//

@testable import SwiftRoonAPI
import XCTest

final class PersistenceTests: XCTestCase {

    private var roonSettings: RoonSettings!

    override func setUp() {
        super.setUp()
        let userDefaults = UserDefaults(suiteName: "testSuite")!
        roonSettings = RoonSettings(userDefaults: userDefaults)
    }

    func testNilRoonState() {
        // Given
        // When
        let roonState = roonSettings.roonState

        // Then
        XCTAssertNil(roonState)
    }

    func testRoonState() {
        // Given
        let roonState = RoonAuthorizationState(tokens: ["TestKey": "TestValue"])

        // When
        roonSettings.roonState = roonState

        // Then
        XCTAssertEqual(roonSettings.roonState, roonState)
    }

    func testPairedCoreID() {
        // Given
        let pairedCoreID = "paired_core_id"

        // When
        roonSettings.pairedCoreID = pairedCoreID

        // Then
        XCTAssertEqual(roonSettings.pairedCoreID, pairedCoreID)
    }

}
