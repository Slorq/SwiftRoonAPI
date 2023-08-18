//
//  SoodTests.swift
//  
//
//  Created by Alejandro Maya on 15/08/23.
//

@testable import SwiftRoonAPI
import XCTest

final class SoodTests: XCTestCase {

    private let socketFactory: _SocketFactory = SocketFactoryMock()
    private var sood: Sood!

    override func setUp() {
        super.setUp()
        InterfacesProviderMock.interfaces = []
        sood = Sood(interfacesProvider: InterfacesProviderMock.self, socketFactory: socketFactory)
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

    func testStopClosesMulticastAndUnicastSockets() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
            .init(ip: "192.168.1.1", netmask: "255.255.255.0"),
        ]

        sood.start(nil)

        sood.testHooks.multicast.forEach { key, value in
            let sendSocketClose = expectation(description: "\(key) sendSocket should be closed")
            value.sendSocket?.testHooks.socket.asMock.closeClosure = { sendSocketClose.fulfill() }
            let receiveSocketClose = expectation(description: "\(key) receiveSocket should be closed")
            value.receiveSocket?.testHooks.socket.asMock.closeClosure = { receiveSocketClose.fulfill() }
        }

        let unicastSendSocketClose = expectation(description: "Unicast sendSocket should be closed")
        sood.testHooks.unicast.sendSocket?.testHooks.socket.asMock.closeClosure = {
            unicastSendSocketClose.fulfill()
        }

        // When
        sood.stop()

        // Then
        waitForExpectations(timeout: 0.5)
    }

    func testQueryServiceIDSendsExpectedMessage() throws {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)

        // When
        sood.query(serviceId: "ServiceID-1")

        // Then
        let expectedPrefixData = "SOOD\u{02}Q".data(using: .utf8)!
        let expectedQueryServiceIDData = "\u{10}query_service_id\0\u{0B}ServiceID-1".data(using: .utf8)!
        XCTAssertEqual(sood.testHooks.multicast.count, 1)
        let multicastSocket = try XCTUnwrap(sood.testHooks.multicast.first?.value.sendSocket?.testHooks.socket.asMock)
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagCallsCount, 2)
        XCTAssertTrue(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].data.contains(expectedPrefixData))
        XCTAssertTrue(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].data.contains(expectedQueryServiceIDData))
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].host, "239.255.90.90")
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].port, 9003)
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].timeout, 10)
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].tag, 1)

        XCTAssertTrue(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[1].data.contains(expectedPrefixData))
        XCTAssertTrue(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[1].data.contains(expectedQueryServiceIDData))
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[1].host, "127.0.0.255")
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[1].port, 9003)
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[1].timeout, 10)
        XCTAssertEqual(multicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[1].tag, 2)
        let unicastSocket = try XCTUnwrap(sood.testHooks.unicast.sendSocket?.testHooks.socket.asMock)
        XCTAssertEqual(unicastSocket.sendToHostPortWithTimeoutTagCallsCount, 1)

        XCTAssertTrue(unicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].data.contains(expectedPrefixData))
        XCTAssertTrue(unicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].data.contains(expectedQueryServiceIDData))
        XCTAssertEqual(unicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].host, "239.255.90.90")
        XCTAssertEqual(unicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].port, 9003)
        XCTAssertEqual(unicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].timeout, 10)
        XCTAssertEqual(unicastSocket.sendToHostPortWithTimeoutTagReceivedInvocations[0].tag, 3)
    }

}

extension _AsyncSocket {

    var asMock: _AsyncSocketMock { self as! _AsyncSocketMock }
}
