//
//  MooEncoderTests.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

import XCTest
@testable import SwiftRoonAPI

final class MooEncoderTests: XCTestCase {

    private let encoder = MooEncoder()

    func testEncodingSuccessfully() {
        // Given
        let messages: [MooMessage] = [
            MooMessage(requestID: 1, verb: SwiftRoonAPI.MooVerb.complete, name: .success),
            MooMessage(requestID: 0, verb: SwiftRoonAPI.MooVerb.request, name: .info),
            MooMessage(requestID: 1, verb: SwiftRoonAPI.MooVerb.request, name: .register, headers: [SwiftRoonAPI.MooHeaderName.contentType: .applicationJson], body: RoonExtensionRegInfo.makeEncoded()),
            MooMessage(requestID: 2, verb: SwiftRoonAPI.MooVerb.request, name: "com.roonlabs.transport:2/subscribe_zones", body: try! SubscriptionBody.makeEncoded()),
        ]

        messages.forEach { message in
            // When
            let encodedMessage = encoder.encode(message: message)

            // Then
            XCTAssertNotNil(encodedMessage)
        }
    }

}
