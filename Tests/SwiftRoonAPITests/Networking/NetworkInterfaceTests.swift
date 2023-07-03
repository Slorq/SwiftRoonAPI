//
//  NetworkInterfaceTests.swift
//  
//
//  Created by Alejandro Maya on 3/07/23.
//

import XCTest
@testable import SwiftRoonAPI

private typealias TestCase = (networkInterface: NetworkInterface, expectedNetwork: String, expectedBroadcast: String)

final class NetworkInterfaceTests: XCTestCase {

    func testNetworkInterface() {
        // Given
        let testCases: [TestCase] = [
            (NetworkInterface(ip: "192.168.1.23", netmask: "255.255.255.0"), "192.168.1.0", "192.168.1.255"),
            (NetworkInterface(ip: "192.168.1.23", netmask: "255.255.0.0"), "192.168.0.0", "192.168.255.255"),
        ]

        // Then
        testCases.forEach { testCase in
            let networkInterface = testCase.networkInterface
            XCTAssertEqual(networkInterface.network, testCase.expectedNetwork)
            XCTAssertEqual(networkInterface.broadcast, testCase.expectedBroadcast)
        }
    }

}
