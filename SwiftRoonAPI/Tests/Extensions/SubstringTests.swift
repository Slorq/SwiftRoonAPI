//
//  SubstringTests.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import XCTest
@testable import SwiftRoonAPI

final class SubstringTests: XCTestCase {

    func testToString() {
        // Given
        let string = "test string"
        let substring = Substring(stringLiteral: string)

        // When
        let returnedString = substring.toString()

        // Then
        XCTAssertEqual(returnedString, string)
    }

    func testToInt() {
        // Given
        let number = 20
        let substring = Substring(stringLiteral: "\(number)")

        // When
        let returnedNumber = substring.toInt()

        // Then
        XCTAssertEqual(returnedNumber, number)
    }

    func testToIntReturnsNilForInvalidString() {
        // Given
        let string = Substring(stringLiteral: "this is not a number")

        // When
        let returnedNumber = string.toInt()

        // Then
        XCTAssertNil(returnedNumber)
    }
}
