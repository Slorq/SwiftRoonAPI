//
//  StringTests.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import XCTest
@testable import SwiftRoonAPI

final class StringTests: XCTestCase {

    func testDroppingPrefix() {
        // Given
        let prefix = "some_prefix"
        let suffix = "some_suffix"
        var string = "\(prefix)\(suffix)"

        // When
        let returnedPrefix = string.droppingPrefix(prefix.count)

        // Then
        XCTAssertEqual(returnedPrefix, prefix)
        XCTAssertEqual(string, suffix)
    }

    func testDroppingFirst() {
        // Given
        let prefix = "some_prefix"
        let suffix = "some_suffix"
        var string = "\(prefix)\(suffix)"

        // When
        string.droppingFirst(prefix.count)

        // Then
        XCTAssertEqual(string, suffix)
    }

    func testToInt() {
        // Given
        let number = 20
        let string = "\(number)"

        // When
        let returnedNumber = string.toInt()

        // Then
        XCTAssertEqual(returnedNumber, number)
    }

    func testToIntForInvalidString() {
        // Given
        let string = "this is not a number"

        // When
        let returnedNumber = string.toInt()

        // Then
        XCTAssertNil(returnedNumber)
    }

    func testIntComponents() {
        // Given
        let string = "172.0.0.1"

        // When
        let components = string.intComponents()

        // Then
        XCTAssertEqual(components.count, 4)
        XCTAssertEqual(components[0], 172)
        XCTAssertEqual(components[1], 0)
        XCTAssertEqual(components[2], 0)
        XCTAssertEqual(components[3], 1)
    }
}
