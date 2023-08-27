//
//  MooTests.swift
//  
//
//  Created by Alejandro Maya on 3/07/23.
//

@testable import SwiftRoonAPI
import SwiftRoonAPICore
import XCTest

final class MooTests: XCTestCase {

    private var transport: _MooTransportMock!
    private var moo: Moo!

    override func setUp() {
        transport = _MooTransportMock()
        moo = Moo(transport: transport)
    }

    func testConnectingWebSocketResumesTransport() {
        // Given
        // When
        moo.connectWebSocket()

        // Then
        XCTAssertTrue(transport.resumeCalled)
        XCTAssertEqual(transport.resumeCallsCount, 1)
    }

    func testSendingRequestCallsSendAndStoresRequestHandler() {
        // Given
        let requestID = moo.testHooks.requestID

        // When
        moo.sendRequest(name: "requestName") { _ in }

        // Then
        XCTAssertTrue(transport.sendDataCalled)
        XCTAssertEqual(transport.sendDataCallsCount, 1)
        XCTAssertEqual(moo.testHooks.requestHandlers.count, 1)
        XCTAssertEqual(moo.testHooks.requestID, requestID + 1)
    }

    func testSendingCompleteCallsSendAndStoresRequestHandler() {
        // Given
        let requestID = moo.testHooks.requestID

        // When
        moo.sendComplete(
            message: .init(requestID: requestID, verb: .continue, name: "name")
        ) { _ in }

        // Then
        XCTAssertTrue(transport.sendDataCalled)
        XCTAssertEqual(transport.sendDataCallsCount, 1)
        XCTAssertEqual(moo.testHooks.requestHandlers.count, 1)
        XCTAssertEqual(moo.testHooks.requestID, requestID + 1)
    }

    func testSendingContinueCallsSendAndStoresRequestHandler() {
        // Given
        let requestID = moo.testHooks.requestID

        // When
        moo.sendContinue(
            message: .init(requestID: requestID, verb: .continue, name: "MooName")
        ) { _ in }

        // Then
        XCTAssertTrue(transport.sendDataCalled)
        XCTAssertEqual(transport.sendDataCallsCount, 1)
        XCTAssertEqual(moo.testHooks.requestHandlers.count, 1)
        XCTAssertEqual(moo.testHooks.requestID, requestID + 1)
    }

    func testSendingSubscribeHelperCallsSendAndStoresRequestHandler() {
        // Given
        let requestID = moo.testHooks.requestID

        // When
        moo.subscribeHelper(
            serviceName: "service_name",
            requestName: "request_name"
        ) { _ in }

        // Then
        XCTAssertTrue(transport.sendDataCalled)
        XCTAssertEqual(transport.sendDataCallsCount, 1)
        XCTAssertEqual(moo.testHooks.requestHandlers.count, 1)
        XCTAssertEqual(moo.testHooks.requestID, requestID + 1)
    }

    func testCleaningUpFinishesAndCleansRequestHandlers() {
        // Given
        let expectCompleteCompletion = expectation(description: "Completion should be called")
        moo.sendComplete(message: .init(requestID: 1, verb: .complete, name: "MooName")) { message in
            if message == nil {
                expectCompleteCompletion.fulfill()
            } else {
                XCTFail("Shouldn't pass a non-nil message")
            }
        }
        let expectContinueCompletion = expectation(description: "Completion should be called")
        moo.sendContinue(message: .init(requestID: 2, verb: .continue, name: "MooName")) { message in
            if message == nil {
                expectContinueCompletion.fulfill()
            } else {
                XCTFail("Shouldn't pass a non-nil message")
            }
        }
        XCTAssertEqual(moo.testHooks.requestHandlers.count, 2)

        // When
        moo.cleanUp()

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(moo.testHooks.requestHandlers.count, 0)
    }

    func testWhenCloseIsCalledThenTransportIsClosed() {
        // Given
        // When
        moo.close()

        // Then
        XCTAssertTrue(transport.closeCalled)
        XCTAssertEqual(transport.closeCallsCount, 1)
    }

    func testWhenTransportOpensOnOpenIsCalled() {
        // Given
        let expectation = expectation(description: "onOpen should be called")
        moo.onOpen = { _ in
            expectation.fulfill()
        }

        // When
        moo.transportDidOpen(_MooTransportMock())

        // Then
        waitForExpectations(timeout: 1)
    }

    func testWhenTransportClosesOnCloseIsCalled() {
        // Given
        let expectation = expectation(description: "onClose should be called")
        moo.onClose = { _ in
            expectation.fulfill()
        }

        // When
        moo.transportDidClose(_MooTransportMock())

        // Then
        waitForExpectations(timeout: 1)
    }

    func testWhenTransportNotifiesErrorOnErrorIsCalled() {
        // Given
        let error = NSError(domain: "TestDomain", code: 1)
        let expectation = expectation(description: "onError should be called")
        moo.onError = { _, notifiedError in
            expectation.fulfill()
            XCTAssertEqual(notifiedError as NSError, error)
        }

        // When
        moo.transport(_MooTransportMock(), didReceiveError: error)

        // Then
        waitForExpectations(timeout: 1)
    }

    func testWhenTransportReceivesInvalidDataOnErrorIsCalled() {
        // Given
        let data = "InvalidMessage".data(using: .utf8)!
        let expectation = expectation(description: "onError should be called")
        moo.onError = { _, notifiedError in
            expectation.fulfill()
            XCTAssertEqual(notifiedError as? MooDecodeError, MooDecodeError.badFirstLine)
        }

        // When
        moo.transport(_MooTransportMock(), didReceiveData: data)

        // Then
        waitForExpectations(timeout: 1)
    }

    func testWhenTransportReceivesValidDataOnMessageIsCalled() {
        // Given
        let message = MooMessage(requestID: 1,
                                 verb: .continue,
                                 name: "MooName",
                                 headers: [.requestID: "1"])
        let data = MooEncoder().encode(message: message)!
        let expectation = expectation(description: "onMessage should be called")
        moo.onMessage = { _, notifiedMessage in
            expectation.fulfill()
            XCTAssertEqual(notifiedMessage, message)
        }

        // When
        moo.transport(_MooTransportMock(), didReceiveData: data)

        // Then
        waitForExpectations(timeout: 1)
    }

    func testWhenTransportReceivesInvalidStringOnErrorIsCalled() {
        // Given
        let message = "InvalidMessage"
        let expectation = expectation(description: "onError should be called")
        moo.onError = { _, notifiedError in
            expectation.fulfill()
            XCTAssertEqual(notifiedError as? MooDecodeError, MooDecodeError.badFirstLine)
        }

        // When
        moo.transport(_MooTransportMock(), didReceiveString: message)

        // Then
        waitForExpectations(timeout: 1)
    }

    func testWhenTransportReceivesValidStringOnMessageIsCalled() {
        // Given
        let message = MooMessage(requestID: 1,
                                 verb: .continue,
                                 name: "MooName",
                                 headers: [.requestID: "1"])
        let data = MooEncoder().encode(message: message)!
        let stringMessage = String(data: data, encoding: .utf8)!
        let expectation = expectation(description: "onMessage should be called")
        moo.onMessage = { _, notifiedMessage in
            expectation.fulfill()
            XCTAssertEqual(notifiedMessage, message)
        }

        // When
        moo.transport(_MooTransportMock(), didReceiveString: stringMessage)

        // Then
        waitForExpectations(timeout: 1)
    }

    func testHandleInvalidMessage() {
        // Given
        let message = MooMessage(requestID: 1, verb: .continue, name: "MooName")

        // When
        let result = moo.handleMessage(message: message)

        // Then
        XCTAssertFalse(result)
    }

    func testHandleValidMessage() {
        // Given
        let message = MooMessage(requestID: 0,
                                 verb: .continue,
                                 name: "MooName",
                                 headers: [.requestID: "0"])
        let expectation = expectation(description: "Handler should be called")
        moo.sendContinue(message: message) { handledMessage in
            XCTAssertEqual(handledMessage, message)
            expectation.fulfill()
        }

        // When
        let result = moo.handleMessage(message: message)

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertTrue(result)
        XCTAssertEqual(moo.testHooks.requestHandlers.count, 1)
    }

    func testHandleCompleteMessageRemovesHandler() {
        // Given
        let message = MooMessage(requestID: 0,
                                 verb: .complete,
                                 name: "MooName",
                                 headers: [.requestID: "0"])
        let expectation = expectation(description: "Handler should be called")
        moo.sendContinue(message: message) { handledMessage in
            XCTAssertEqual(handledMessage, message)
            expectation.fulfill()
        }

        // When
        let result = moo.handleMessage(message: message)

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertTrue(result)
        XCTAssertEqual(moo.testHooks.requestHandlers.count, 0)
    }

}
