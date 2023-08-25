//
//  MooEncoderTests.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

@testable import SwiftRoonAPI
import SwiftRoonAPICore
import XCTest

final class MooEncoderTests: XCTestCase {

    private let encoder = MooEncoder()

    func testEncodingSuccessfully() {
        // Given
        let messages: [MooMessage] = [
            MooMessage(requestID: 1, verb: MooVerb.complete, name: .success),
            MooMessage(requestID: 0, verb: MooVerb.request, name: .info),
            MooMessage(requestID: 1, verb: MooVerb.request, name: .register, headers: [MooHeaderName.contentType: .applicationJson], body: RoonExtensionCompleteDetails.makeEncoded()),
            MooMessage(requestID: 2, verb: MooVerb.request, name: "com.roonlabs.transport:2/subscribe_zones", body: try! SubscriptionBody.makeEncoded()),
        ]

        messages.forEach { message in
            // When
            let encodedMessage = encoder.encode(message: message)

            // Then
            XCTAssertNotNil(encodedMessage)
        }
    }

}
