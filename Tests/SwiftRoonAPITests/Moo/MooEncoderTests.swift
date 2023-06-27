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
            MooMessage(requestID: 1, verb: SwiftRoonAPI.MooVerb.request, name: .register, headers: [SwiftRoonAPI.MooHeaderName.contentType: "application/json"], body: try! RoonExtensionRegInfo.makeEncoded()),
            MooMessage(requestID: 2, verb: SwiftRoonAPI.MooVerb.request, name: .transport + "/subscribe_" + .zones, body: try! SubscriptionBody.makeEncoded()),
            MooMessage(requestID: 4, verb: SwiftRoonAPI.MooVerb.request, name: .control, body: try! ZoneControl.makeEncoded(.playpause)),
            MooMessage(requestID: 6, verb: SwiftRoonAPI.MooVerb.request, name: .control, body: try! ZoneControl.makeEncoded(.next)),
            MooMessage(requestID: 8, verb: SwiftRoonAPI.MooVerb.request, name: .control, body: try! ZoneControl.makeEncoded(.previous)),
        ]

        messages.forEach { message in
            // When
            let encodedMessage = encoder.encode(message: message)

            // Then
            XCTAssertNotNil(encodedMessage)
        }
    }

}

private extension ZoneControl {

    static func make(_ control: RoonControl) throws -> ZoneControl {
        .init(zoneOrOutputID: "16010d60b4bebac50430d2381c9578c87196",
              control: control)
    }

    static func makeEncoded(_ control: RoonControl) throws -> Data {
        try self.make(control).jsonEncoded()
    }

}

private extension SubscriptionBody {

    static func makeEncoded() throws -> Data {
        try SubscriptionBody(subscriptionKey: "1").jsonEncoded()
    }

}

private extension RoonExtensionRegInfo {

    static func makeEncoded() throws -> Data {
        try RoonExtensionRegInfo(displayName: "Display Name",
                                 displayVersion: "0.0.1",
                                 email: "test@mail.com",
                                 extensionID: "com.coffeeware.roonminiplayer",
                                 publisher: "Slorq",
                                 website: "https://github.com/Slorq/roon-mini-player")
        .jsonEncoded()
    }

}
