//
//  PersistenceTests.swift
//  
//
//  Created by Alejandro Maya on 8/07/23.
//

@testable import SwiftRoonAPI
import XCTest

final class PersistenceTests: XCTestCase {

    func testNilRoonState() {
        // Given
        // When
        let roonState = RoonSettings.roonState

        // Then
        XCTAssertNil(roonState)
    }

    func testRoonState() {
        // Given
        let roonState = RoonAuthorizationState(tokens: ["TestKey": "TestValue"])

        // When
        RoonSettings.roonState = roonState

        // Then
        XCTAssertEqual(RoonSettings.roonState, roonState)
    }

    func testPairedCoreID() {
        // Given
        let pairedCoreID = "paired_core_id"

        // When
        RoonSettings.pairedCoreID = pairedCoreID

        // Then
        XCTAssertEqual(RoonSettings.pairedCoreID, pairedCoreID)
    }

}
