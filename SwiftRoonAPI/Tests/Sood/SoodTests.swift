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

    func testUnicastSocketOnErrorClosesSocket() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)

        // When
        sood.testHooks.unicast.sendSocket?.onError?(NSError(domain: "Test", code: 1))

        // Then
        XCTAssertEqual(sood.testHooks.unicast.sendSocket?.testHooks.socket.asMock.closeCalled, true)
    }

    func testUnicastSocketOnCloseRemovesSocket() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)

        // When
        sood.testHooks.unicast.sendSocket?.onClose?()

        // Then
        XCTAssertNil(sood.testHooks.unicast.sendSocket)
    }

    func testUnicastSocketOnMessageNotifiesMessage() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)
        let requestMessage = MessageInfo(address: "127.0.0.1", port: 9300)
        let responseData = "SOOD\u{02}Q\u{04}_tid\u{00}$2D0712E3-CB9E-44C4-8E7B-E8C0769534E3\u{10}query_service_id\u{00}$00720724-5143-4a9b-abac-0e50cba674bb".data(using: .utf8)!

        let expectation = expectation(description: "On message should be called")
        sood.onMessage = { message in
            XCTAssertEqual(message, .init(props: .init(tid: "2D0712E3-CB9E-44C4-8E7B-E8C0769534E3"),
                                          from: .init(ip: "127.0.0.1", port: 9300),
                                          type: "Q"))
            expectation.fulfill()
        }

        // When
        sood.testHooks.unicast.sendSocket?.onMessage?(responseData, requestMessage)

        // Then
        waitForExpectations(timeout: 0.1)
    }

    func testMulticastSendSocketOnErrorClosesSocket() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)

        // When
        sood.testHooks.multicast.first?.value.sendSocket?.onError?(NSError(domain: "Test", code: 1))

        // Then
        XCTAssertEqual(sood.testHooks.multicast.first?.value.sendSocket?.testHooks.socket.asMock.closeCalled, true)
    }

    func testMulticastSendSocketOnCloseRemovesSocket() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)

        // When
        sood.testHooks.multicast.first?.value.sendSocket?.onClose?()

        // Then
        XCTAssertNil(sood.testHooks.multicast.first?.value.sendSocket)
    }

    func testMulticastSendSocketOnMessageNotifiesMessage() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)
        let requestMessage = MessageInfo(address: "127.0.0.1", port: 9300)
        let responseData = "SOOD\u{02}Q\u{04}_tid\u{00}$2D0712E3-CB9E-44C4-8E7B-E8C0769534E3\u{10}query_service_id\u{00}$00720724-5143-4a9b-abac-0e50cba674bb".data(using: .utf8)!

        let expectation = expectation(description: "On message should be called")
        sood.onMessage = { message in
            XCTAssertEqual(message, .init(props: .init(tid: "2D0712E3-CB9E-44C4-8E7B-E8C0769534E3"),
                                          from: .init(ip: "127.0.0.1", port: 9300),
                                          type: "Q"))
            expectation.fulfill()
        }

        // When
        sood.testHooks.multicast.first?.value.sendSocket?.onMessage?(responseData, requestMessage)

        // Then
        waitForExpectations(timeout: 0.1)
    }

    func testMulticastRecieveSocketOnErrorClosesSocket() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)

        // When
        sood.testHooks.multicast.first?.value.receiveSocket?.onError?(NSError(domain: "Test", code: 1))

        // Then
        XCTAssertEqual(sood.testHooks.multicast.first?.value.receiveSocket?.testHooks.socket.asMock.closeCalled, true)
    }

    func testMulticastReceiveSocketOnCloseRemovesSocket() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)

        // When
        sood.testHooks.multicast.first?.value.receiveSocket?.onClose?()

        // Then
        XCTAssertNil(sood.testHooks.multicast.first?.value.receiveSocket)
    }

    func testMulticastReceiveSocketOnMessageNotifiesMessage() {
        // Given
        InterfacesProviderMock.interfaces = [
            .init(ip: "127.0.0.1", netmask: "255.255.255.0"),
        ]
        sood.start(nil)
        let requestMessage = MessageInfo(address: "127.0.0.1", port: 9300)
        let responseData = "SOOD\u{02}Q\u{04}_tid\u{00}$2D0712E3-CB9E-44C4-8E7B-E8C0769534E3\u{10}query_service_id\u{00}$00720724-5143-4a9b-abac-0e50cba674bb".data(using: .utf8)!

        let expectation = expectation(description: "On message should be called")
        sood.onMessage = { message in
            XCTAssertEqual(message, .init(props: .init(tid: "2D0712E3-CB9E-44C4-8E7B-E8C0769534E3"),
                                          from: .init(ip: "127.0.0.1", port: 9300),
                                          type: "Q"))
            expectation.fulfill()
        }

        // When
        sood.testHooks.multicast.first?.value.receiveSocket?.onMessage?(responseData, requestMessage)

        // Then
        waitForExpectations(timeout: 0.1)
    }

}

extension _AsyncSocket {

    var asMock: _AsyncSocketMock { self as! _AsyncSocketMock }
}
