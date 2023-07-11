//
//  MooTransportTests.swift
//  
//
//  Created by Alejandro Maya on 2/07/23.
//

import Combine
@testable import SwiftRoonAPI
import XCTest

final class MooTransportTests: XCTestCase {

    private let host = "localhost"
    private let port: UInt16 = 9000
    private static var webSocket: _URLSessionWebSocketTaskMock!
    private var webSocket: _URLSessionWebSocketTaskMock {
        Self.webSocket
    }
    private var delegate: MooTransportDelegateMock!
    private static var transport: MooTransport!
    private var transport: MooTransport {
        Self.transport
    }
    private let data = "data".data(using: .utf8)!

    override func setUp() async throws {
        Self.webSocket = _URLSessionWebSocketTaskMock()
        Self.transport = try MooTransport(host: host, port: port, webSocket: webSocket)
        delegate = MooTransportDelegateMock()
        transport.delegate = delegate
        try await super.setUp()
    }

    func testInitWithInvalidURLThrowsError() {
        // Given
        let host = "     "
        let port: UInt16 = 8080

        // When
        XCTAssertThrowsError(try MooTransport(host: host, port: port), "Should throw error") { error in
            // Then
            if error as? MooTransportError != .invalidURL {
                XCTFail("Expected .invalidURL error")
            }
        }
    }

    func testResumeCallsWebSocketResume() {
        // When
        transport.resume()

        // Then
        XCTAssertTrue(webSocket.resumeCalled)
        XCTAssertEqual(webSocket.resumeCallsCount, 1)
    }

    func testSendCallsWebSocketSend() {
        // When
        transport.send(data: data)

        // Then
        XCTAssertTrue(webSocket.sendCompletionHandlerCalled)
        XCTAssertEqual(webSocket.sendCompletionHandlerCallsCount, 1)
    }

    func testReceiveValidErrorSendingDataCallsDelegate() {
        // Given
        let mockError = NSError()
        setWebSocketAlive()
        webSocket.sendCompletionHandlerClosure = { message, completion in
            completion(mockError)
        }

        // When
        transport.send(data: data)

        // Then
        XCTAssertTrue(webSocket.receiveCompletionHandlerCalled)
        XCTAssertEqual(webSocket.receiveCompletionHandlerCallsCount, 1)
        XCTAssertTrue(delegate.transportDidReceiveErrorCalled)
        XCTAssertEqual(delegate.transportDidReceiveErrorCallsCount, 1)
        XCTAssertEqual(delegate.transportDidReceiveErrorReceivedArguments?.error as? NSError, mockError)
    }

    func testReceiveNilErrorCallsReceive() {
        // Given
        setWebSocketAlive()

        // When
        transport.send(data: data)

        // Then
        XCTAssertTrue(webSocket.receiveCompletionHandlerCalled)
        XCTAssertEqual(webSocket.receiveCompletionHandlerCallsCount, 1)
    }

    func testCloseClosesWebSocketAndNotifiesDelegate() {
        // When
        transport.close()

        // Then
        XCTAssertTrue(webSocket.cancelWithReasonCalled)
        XCTAssertEqual(webSocket.cancelWithReasonCallsCount, 1)
        XCTAssertTrue(delegate.transportDidCloseCalled)
        XCTAssertEqual(delegate.transportDidCloseCallsCount, 1)
    }

    func testReceivingDataNotifiesDelegate() {
        // Given
        setWebSocketAlive()

        // When
        transport.send(data: data)
        webSocket.receiveCompletionHandlerReceivedCompletionHandler?(.success(.data(data)))

        // Then
        XCTAssertTrue(delegate.transportDidReceiveDataCalled)
        XCTAssertEqual(delegate.transportDidReceiveDataCallsCount, 1)
        XCTAssertEqual(delegate.transportDidReceiveDataReceivedArguments?.data, data)
    }

    func testReceivingStringNotifiesDelegate() {
        // Given
        let string = "string"
        setWebSocketAlive()

        // When
        transport.send(data: data)
        webSocket.receiveCompletionHandlerReceivedCompletionHandler?(.success(.string(string)))

        // Then
        XCTAssertTrue(delegate.transportDidReceiveStringCalled)
        XCTAssertEqual(delegate.transportDidReceiveStringCallsCount, 1)
        XCTAssertEqual(delegate.transportDidReceiveStringReceivedArguments?.string, string)
    }

    func testReceivingCloseFailureCancelsSocketAndNotifiesDelegate() throws {
        // Given
        let errorCodes = [57, 60, 54]

        try errorCodes.forEach { errorCode in
            let webSocket = _URLSessionWebSocketTaskMock()
            let transport = try MooTransport(host: host, port: port, webSocket: webSocket)
            let delegate = MooTransportDelegateMock()
            transport.delegate = delegate
            setWebSocketAlive(webSocket: webSocket, transport: transport)
            let error = NSError(domain: "TestDomain", code: errorCode)

            // When
            transport.send(data: data)
            webSocket.receiveCompletionHandlerReceivedCompletionHandler?(.failure(error))

            // Then
            XCTAssertTrue(webSocket.cancelWithReasonCalled)
            XCTAssertEqual(webSocket.cancelWithReasonCallsCount, 1)
            XCTAssertTrue(delegate.transportDidCloseCalled)
            XCTAssertEqual(delegate.transportDidCloseCallsCount, 1)
        }
    }

    func testReceivingFailureNotifiesDelegate() {
        // Given
        let error = NSError(domain: "TestDomain", code: 1)
        setWebSocketAlive()

        // When
        transport.send(data: data)
        webSocket.receiveCompletionHandlerReceivedCompletionHandler?(.failure(error))

        // Then
        XCTAssertTrue(delegate.transportDidReceiveErrorCalled)
        XCTAssertEqual(delegate.transportDidReceiveErrorCallsCount, 1)
        XCTAssertEqual(delegate.transportDidReceiveErrorReceivedArguments?.error as? NSError, error)
    }
    
    func testDelegateIsNotifiedWhenSocketOpens() throws {
        // Given
        let webSocket = _URLSessionWebSocketTaskMock()
        let timer = TimerMock()
        let transport = try MooTransport(host: host, port: port, webSocket: webSocket, timerPublisher: timer)
        let delegate = MooTransportDelegateMock()
        transport.delegate = delegate

        let urlSession = URLSession.shared

        // When
        transport.urlSession(urlSession,
                             webSocketTask: urlSession.webSocketTask(with: .init(string: "ws://\(host):\(port)/api")!),
                             didOpenWithProtocol: nil)

        // Then
        XCTAssertTrue(delegate.transportDidOpenCalled)
        XCTAssertEqual(delegate.transportDidOpenCallsCount, 1)
        timer.publisher.send(.now)
        XCTAssertTrue(webSocket.sendPingPongReceiveHandlerCalled)
        XCTAssertEqual(webSocket.sendPingPongReceiveHandlerCallsCount, 1)
    }

    func testMissingAHeartbeatClosesConnection() throws {
        // Given
        let webSocket = _URLSessionWebSocketTaskMock()
        let timer = TimerMock()
        let transport = try MooTransport(host: host, port: port, webSocket: webSocket, timerPublisher: timer)
        let delegate = MooTransportDelegateMock()
        transport.delegate = delegate
        setWebSocketAlive(webSocket: webSocket, transport: transport, cleanClosures: true)

        // When
        timer.publisher.send(.now)
        webSocket.sendPingPongReceiveHandlerReceivedPongReceiveHandler?(NSError(domain: "TestDomain", code: 1))
        timer.publisher.send(.now)

        // Then
        XCTAssertTrue(webSocket.sendPingPongReceiveHandlerCalled)
        XCTAssertEqual(webSocket.sendPingPongReceiveHandlerCallsCount, 1)
        XCTAssertFalse(transport.isAlive)
    }


    func testDelegateIsNotifiedWhenSocketCloses() {
        // Given
        let urlSession = URLSession.shared

        // When
        transport.urlSession(urlSession,
                             webSocketTask: urlSession.webSocketTask(with: .init(string: "ws://\(host):\(port)/api")!),
                             didCloseWith: .goingAway,
                             reason: nil)

        // Then
        XCTAssertTrue(delegate.transportDidCloseCalled)
        XCTAssertEqual(delegate.transportDidCloseCallsCount, 1)
    }

    func testDelegateIsNotifiedWhenSocketCompletesWithError() {
        // Given
        let error = NSError(domain: "TestDomain", code: 1)
        let urlSession = URLSession.shared

        // When
        transport.urlSession(urlSession,
                             task: urlSession.webSocketTask(with: .init(string: "ws://\(host):\(port)/api")!),
                             didCompleteWithError: error)

        // Then
        XCTAssertTrue(delegate.transportDidReceiveErrorCalled)
        XCTAssertEqual(delegate.transportDidReceiveErrorCallsCount, 1)
    }

}

private extension MooTransportTests {

    func setWebSocketAlive(webSocket: _URLSessionWebSocketTaskMock = MooTransportTests.webSocket,
                           transport: MooTransport = MooTransportTests.transport,
                           cleanClosures: Bool = false) {
        defer {
            if cleanClosures {
                webSocket.sendCompletionHandlerClosure = nil
                webSocket.sendPingPongReceiveHandlerClosure = nil
            }
        }
        webSocket.sendCompletionHandlerClosure = { _, completion in
            completion(nil)
        }
        webSocket.sendPingPongReceiveHandlerClosure = { completion in
            completion(nil)
        }
        let urlSession = URLSession.shared
        transport.urlSession(urlSession, webSocketTask: urlSession.webSocketTask(with: .init(string: "ws://\(host):\(port)/api")!), didOpenWithProtocol: nil)
        webSocket.sendPingPongReceiveHandlerReceivedPongReceiveHandler?(nil)
    }

}

private struct TimerMock: TimerProtocol {

    var publisher = PassthroughSubject<Date, Never>()

    func getTimerPublisher() -> AnyPublisher<Date, Never> {
        publisher.eraseToAnyPublisher()
    }
}
