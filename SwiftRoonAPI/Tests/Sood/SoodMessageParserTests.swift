//
//  File.swift
//  
//
//  Created by Alejandro Maya on 16/08/23.
//

import Foundation

@testable import SwiftRoonAPI
import XCTest

final class SoodMessageParserTests: XCTestCase {

    private let parser = SoodMessageParser()
    private let messageInfo = MessageInfo(address: "127.0.0.1", port: 8080)

    func testParsingSoodMessage() {
        // Given
        let testCases: [String: SoodMessage] = [
            "SOOD\u{02}Q\u{04}_tid\u{00}$2D0712E3-CB9E-44C4-8E7B-E8C0769534E3\u{10}query_service_id\u{00}$00720724-5143-4a9b-abac-0e50cba674bb":
                    .init(props: .init(tid: "2D0712E3-CB9E-44C4-8E7B-E8C0769534E3"),
                          from: .init(ip: "127.0.0.1",
                                      port: 8080),
                          type: "Q"),
            "SOOD\u{02}R\u{04}name\u{00}\u{16}Alejandros-MacBook-Pro\u{0f}display_version\u{00}\u{1b}2.0 (build 1299) production\tunique_id\u{00}$fc519bd4-30c9-4e38-b8ea-53f5816ba75e":
                    .init(props: .init(uniqueId: "fc519bd4-30c9-4e38-b8ea-53f5816ba75e",
                                       displayVersion: "2.0 (build 1299) production",
                                       name: "Alejandros-MacBook-Pro"),
                          from: .init(ip: "127.0.0.1",
                                      port: 8080),
                          type: "R")
        ]

        testCases.forEach { string, expectedMessage in
            // When
            let soodMessage = parser.parse(string, messageInfo: messageInfo)

            // Then
            XCTAssertEqual(soodMessage, expectedMessage)
        }
    }

}
