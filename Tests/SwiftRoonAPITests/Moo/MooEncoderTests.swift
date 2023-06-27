//
//  MooEncoderTests.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

import XCTest
@testable import SwiftRoonAPI

final class MooEncoderTests: XCTestCase {

    let encoder = MooEncoder()

    func testEncodingSuccessfully() {
        // Given
        let messages: [MooMessage] = [
            MooMessage(requestID: 1, verb: SwiftRoonAPI.MooVerb.complete, name: "Success"),
            MooMessage(requestID: 0, verb: SwiftRoonAPI.MooVerb.request, name: "com.roonlabs.registry:1/info"),
            MooMessage(requestID: 1, verb: SwiftRoonAPI.MooVerb.request, name: "com.roonlabs.registry:1/register", headers: [SwiftRoonAPI.MooHeaderName.contentType: "application/json"], body: "{\"provided_services\":[\"com.roonlabs.ping:1\"],\"required_services\":[\"com.roonlabs.transport:2\"],\"website\":\"https:\\/\\/github.com\\/Slorq\\/roon-mini-player\",\"optional_services\":[],\"email\":\"test@mail.com\",\"publisher\":\"Slorq\",\"display_name\":\"Mini Display MacOS\",\"token\":\"78853ef6-e1f7-4d84-902d-88e0cdd60b05\",\"extension_id\":\"com.coffeeware.minidisplay\",\"display_version\":\"0.0.1\"}".data(using: .utf8)),
            MooMessage(requestID: 2, verb: SwiftRoonAPI.MooVerb.request, name: "com.roonlabs.transport:2/subscribe_zones", body: "{\"subscription_key\":1}".data(using: .utf8)),
            MooMessage(requestID: 4, verb: SwiftRoonAPI.MooVerb.request, name: "com.roonlabs.transport:2/control", body: "{\"zone_or_output_id\": \"16010d60b4bebac50430d2381c9578c87196\", \"control\": \"playpause\"}".data(using: .utf8)),
            MooMessage(requestID: 6, verb: SwiftRoonAPI.MooVerb.request, name: "com.roonlabs.transport:2/control", body: "{\"zone_or_output_id\": \"16010d60b4bebac50430d2381c9578c87196\", \"control\": \"next\"}".data(using: .utf8)),
            MooMessage(requestID: 8, verb: SwiftRoonAPI.MooVerb.request, name: "com.roonlabs.transport:2/control", body: "{\"zone_or_output_id\": \"16010d60b4bebac50430d2381c9578c87196\", \"control\": \"previous\"}".data(using: .utf8)),
        ]

        messages.forEach { message in
        // When
            let encodedMessage = encoder.encode(message: message)

        // Then
            XCTAssertNotNil(encodedMessage)
        }
    }

}
