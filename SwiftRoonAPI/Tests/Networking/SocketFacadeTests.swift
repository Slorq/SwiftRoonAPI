//
//  SocketTests.swift
//  
//
//  Created by Alejandro Maya on 8/07/23.
//

import XCTest
@testable import SwiftRoonAPI

final class SocketFacadeTests: XCTestCase {

    private let mockSocket = _AsyncSocketMock()
    private let port: UInt16 = 80
    private var socket: SocketFacade!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.socket = try SocketFacade(port: port, socket: mockSocket)
    }

    func testInit() throws {
        // Given
        let mockSocket = _AsyncSocketMock()

        // When
        _ = try SocketFacade(port: port, socket: mockSocket)

        // Then
        XCTAssertEqual(mockSocket.setDelegateDelegateQueueCallsCount, 1)
        XCTAssertEqual(mockSocket.enableReusePortCallsCount, 1)
        XCTAssertEqual(mockSocket.bindToPortCallsCount, 1)
        XCTAssertEqual(mockSocket.enableBroadcastCallsCount, 1)
        XCTAssertEqual(mockSocket.beginReceivingCallsCount, 1)
    }

    func testInitWithAddress() throws {
        // Given
        let address = "127.0.0.1"
        let mockSocket = _AsyncSocketMock()

        // When
        _ = try SocketFacade(port: port, address: address, socket: mockSocket)

        // Then
        XCTAssertEqual(mockSocket.setDelegateDelegateQueueCallsCount, 1)
        XCTAssertEqual(mockSocket.enableReusePortCallsCount, 1)
        XCTAssertFalse(mockSocket.bindToPortCalled)
        XCTAssertEqual(mockSocket.bindToPortInterfaceCallsCount, 1)
        XCTAssertEqual(mockSocket.bindToPortInterfaceReceivedArguments?.interface, address)
        XCTAssertEqual(mockSocket.enableBroadcastCallsCount, 1)
        XCTAssertEqual(mockSocket.beginReceivingCallsCount, 1)
    }

    func testInitWithMulticastGroup() throws {
        // Given
        let group = "group"
        let interface = "127.0.0.1"
        let mockSocket = _AsyncSocketMock()

        // When
        _ = try SocketFacade(port: port, joinMulticastGroup: group, onInterface: interface, socket: mockSocket)

        // Then
        XCTAssertEqual(mockSocket.setDelegateDelegateQueueCallsCount, 1)
        XCTAssertEqual(mockSocket.enableReusePortCallsCount, 1)
        XCTAssertEqual(mockSocket.bindToPortCallsCount, 1)
        XCTAssertEqual(mockSocket.enableBroadcastCallsCount, 1)
        XCTAssertEqual(mockSocket.beginReceivingCallsCount, 1)
        XCTAssertEqual(mockSocket.joinMulticastGroupOnInterfaceCallsCount, 1)
        XCTAssertEqual(mockSocket.joinMulticastGroupOnInterfaceReceivedArguments?.group, group)
        XCTAssertEqual(mockSocket.joinMulticastGroupOnInterfaceReceivedArguments?.interface, interface)
    }

    func testInitThrowsOnError() throws {
        // Given
        let mockSocket = _AsyncSocketMock()
        mockSocket.enableReusePortThrowableError = NSError(domain: "TestDomain", code: -1)

        do {
            // When
            _ = try SocketFacade(port: port, socket: mockSocket)
        } catch {
            // Then
            XCTAssertEqual(error as? SocketError, SocketError.unableToCreateSocket)
        }
    }

    func testSendDataCallsSendData() {
        // Given
        let data = "data".data(using: .utf8)!
        let host = "localhost"
        let timeout: TimeInterval = 10
        let tag = 1

        // When
        socket.send(data, toHost: host, port: port, withTimeout: timeout, tag: tag)

        // Then
        XCTAssertEqual(mockSocket.sendToHostPortWithTimeoutTagCallsCount, 1)
        XCTAssertEqual(mockSocket.sendToHostPortWithTimeoutTagReceivedArguments?.data, data)
        XCTAssertEqual(mockSocket.sendToHostPortWithTimeoutTagReceivedArguments?.host, host)
        XCTAssertEqual(mockSocket.sendToHostPortWithTimeoutTagReceivedArguments?.port, port)
        XCTAssertEqual(mockSocket.sendToHostPortWithTimeoutTagReceivedArguments?.timeout, timeout)
        XCTAssertEqual(mockSocket.sendToHostPortWithTimeoutTagReceivedArguments?.tag, tag)
    }

    func testCloseCallsClose() {
        // Given
        // When
        socket.close()

        // Then
        XCTAssertEqual(mockSocket.closeCallsCount, 1)
    }

    func testIsClosedCallsIsClosed() {
        // Given
        mockSocket.isClosedReturnValue = false

        // When
        let isClosed = socket.isClosed()

        // Then
        XCTAssertEqual(mockSocket.isClosedCallsCount, 1)
        XCTAssertFalse(isClosed)
    }

    func testErrorConnectingCallsOnError() {
        // Given
        let error = NSError(domain: "TestDomain", code: -1)
        let expectation = expectation(description: "Should call onError")
        socket.onError = { returnedError in
            XCTAssertEqual(returnedError as? NSError, error)
            expectation.fulfill()
        }

        // When
        socket.udpSocket(.init(), didNotConnect: error)

        // Then
        waitForExpectations(timeout: 10)
    }

    func testErrorSendingDataCallsOnError() {
        // Given
        let error = NSError(domain: "TestDomain", code: -1)
        let expectation = expectation(description: "Should call onError")
        socket.onError = { returnedError in
            XCTAssertEqual(returnedError as? NSError, error)
            expectation.fulfill()
        }

        // When
        socket.udpSocket(.init(), didNotSendDataWithTag: 1, dueToError: error)

        // Then
        waitForExpectations(timeout: 10)
    }

    func testReceivingDataCallsOnMessage() {
        // Given
        let data = "data".data(using: .utf8)!
        let address = "127.0.0.1"
        let addressData = address.data(using: .utf8)!
        let expectation = expectation(description: "Should call onError")
        socket.onMessage = { (returnedData, messageInfo) in
            XCTAssertEqual(returnedData, data)
            expectation.fulfill()
        }

        // When
        socket.udpSocket(.init(), didReceive: data, fromAddress: addressData, withFilterContext: nil)

        // Then
        waitForExpectations(timeout: 10)
    }

    func testOnCloseCallsOnClose() {
        // Given
        let expectation = expectation(description: "Should call onError")
        socket.onClose = {
            expectation.fulfill()
        }

        // When
        socket.udpSocketDidClose(.init(), withError: nil)

        // Then
        waitForExpectations(timeout: 10)
    }

}
