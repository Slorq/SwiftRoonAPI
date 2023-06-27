//
//  MooDecoderTests.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

import XCTest
@testable import SwiftRoonAPI

final class MooDecoderTests: XCTestCase {

    let decoder = MooDecoder()

    func testDecodeEmptyData() throws {
        // Given
        let data = Data()

        // When
        let decodedMessage = try decoder.decode(data)

        // Then
        XCTAssertNil(decodedMessage)
    }

    func testDecodeInvalidData() {
        // Given
        let data = Data([1, 210, 45, 39])

        do {
            // When
            _ = try decoder.decode(data)
            XCTFail("Should throw an error")
        } catch {
            // Then
            XCTAssertEqual(error as? MooDecodeError, MooDecodeError.unrecognizedData)
        }
    }

    func testDecodeValidData() throws {
        // Given
        guard let data = MooMessageMock.completeSuccess.data(using: .utf8) else {
            XCTFail("Unable to create data")
            return
        }

        // When
        let decodedMessage = try decoder.decode(data)

        // Then
        XCTAssertNotNil(decodedMessage)
    }


    func testDecodeMessageSuccessfully() throws {
        // Given
        let messages: [MooMessageMock] = [
            .completeSuccess,
            .continueChanged,
            .continueRegistered,
            .continueSubscribed,
            .request,
        ]

        try messages.forEach { message in
            // When
            let decodedMessage = try decoder.decode(message)

            // Then
            XCTAssertNotNil(decodedMessage)
        }
    }

    func testDecodeInvalidStringThrowsExpectedError() {
        // Given
        let testCases: [(message: MooMessageMock, expectedError: MooDecodeError)] = [
            (.invalidFirstLine, .badFirstLine),
            (.invalidVerb, .unrecognizedVerb),
            (.invalidFirstLineEnding, .badFirstLine),
            (.invalidHeadersDelimiting, .unableToDelimitHeaders),
            (.invalidHeaderLine, .badHeaderLine),
            (.invalidHeaderName, .unrecognizedHeader),
            (.missingRequestID, .missingRequestID),
        ]

        testCases.forEach { testCase in
            do {
                // When
                _ = try decoder.decode(testCase.message)
                XCTFail("Should throw an error")
            } catch {
                // Then
                let thrownError = error as? MooDecodeError
                XCTAssertEqual(thrownError, testCase.expectedError)
            }
        }
    }

}
