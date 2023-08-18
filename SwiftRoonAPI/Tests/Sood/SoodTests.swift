//
//  SoodTests.swift
//  
//
//  Created by Alejandro Maya on 15/08/23.
//

@testable import SwiftRoonAPI
import XCTest

final class SoodTests: XCTestCase {

    private var sood: Sood!

    override func setUp() {
        super.setUp()
        InterfacesProviderMock.interfaces = []
        sood = Sood(interfacesProvider: InterfacesProviderMock.self)
    }

    func testStartCreatesMulticastInterface() {
        // Given
        let ip = "127.0.0.1"
        InterfacesProviderMock.interfaces = [
            .init(ip: ip, netmask: "255.255.255.0")
        ]

        // When
        sood.start(nil)

        // Then
        XCTAssertEqual(sood.testHooks.multicast.count, 1)
        let multicastInterface = sood.testHooks.multicast[ip]
        XCTAssertNotNil(multicastInterface?.sendSocket)
        XCTAssertNotNil(multicastInterface?.receiveSocket)
        XCTAssertEqual(multicastInterface?.interfaceSequence, 1)
        XCTAssertEqual(multicastInterface?.broadcast, "127.0.0.255")

        XCTAssertNotNil(sood.testHooks.unicast.sendSocket)
    }

}
