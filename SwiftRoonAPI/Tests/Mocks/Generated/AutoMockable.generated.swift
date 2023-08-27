// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif


@testable import SwiftRoonAPI






















class MooTransportDelegateMock: MooTransportDelegate {




    //MARK: - transportDidOpen

    var transportDidOpenCallsCount = 0
    var transportDidOpenCalled: Bool {
        return transportDidOpenCallsCount > 0
    }
    var transportDidOpenReceivedTransport: _MooTransport?
    var transportDidOpenReceivedInvocations: [_MooTransport] = []
    var transportDidOpenClosure: ((_MooTransport) -> Void)?

    func transportDidOpen(_ transport: _MooTransport) {
        transportDidOpenCallsCount += 1
        transportDidOpenReceivedTransport = transport
        transportDidOpenReceivedInvocations.append(transport)
        transportDidOpenClosure?(transport)
    }

    //MARK: - transportDidClose

    var transportDidCloseCallsCount = 0
    var transportDidCloseCalled: Bool {
        return transportDidCloseCallsCount > 0
    }
    var transportDidCloseReceivedTransport: _MooTransport?
    var transportDidCloseReceivedInvocations: [_MooTransport] = []
    var transportDidCloseClosure: ((_MooTransport) -> Void)?

    func transportDidClose(_ transport: _MooTransport) {
        transportDidCloseCallsCount += 1
        transportDidCloseReceivedTransport = transport
        transportDidCloseReceivedInvocations.append(transport)
        transportDidCloseClosure?(transport)
    }

    //MARK: - transport

    var transportDidReceiveErrorCallsCount = 0
    var transportDidReceiveErrorCalled: Bool {
        return transportDidReceiveErrorCallsCount > 0
    }
    var transportDidReceiveErrorReceivedArguments: (transport: _MooTransport, error: Error)?
    var transportDidReceiveErrorReceivedInvocations: [(transport: _MooTransport, error: Error)] = []
    var transportDidReceiveErrorClosure: ((_MooTransport, Error) -> Void)?

    func transport(_ transport: _MooTransport, didReceiveError error: Error) {
        transportDidReceiveErrorCallsCount += 1
        transportDidReceiveErrorReceivedArguments = (transport: transport, error: error)
        transportDidReceiveErrorReceivedInvocations.append((transport: transport, error: error))
        transportDidReceiveErrorClosure?(transport, error)
    }

    //MARK: - transport

    var transportDidReceiveDataCallsCount = 0
    var transportDidReceiveDataCalled: Bool {
        return transportDidReceiveDataCallsCount > 0
    }
    var transportDidReceiveDataReceivedArguments: (transport: _MooTransport, data: Data)?
    var transportDidReceiveDataReceivedInvocations: [(transport: _MooTransport, data: Data)] = []
    var transportDidReceiveDataClosure: ((_MooTransport, Data) -> Void)?

    func transport(_ transport: _MooTransport, didReceiveData data: Data) {
        transportDidReceiveDataCallsCount += 1
        transportDidReceiveDataReceivedArguments = (transport: transport, data: data)
        transportDidReceiveDataReceivedInvocations.append((transport: transport, data: data))
        transportDidReceiveDataClosure?(transport, data)
    }

    //MARK: - transport

    var transportDidReceiveStringCallsCount = 0
    var transportDidReceiveStringCalled: Bool {
        return transportDidReceiveStringCallsCount > 0
    }
    var transportDidReceiveStringReceivedArguments: (transport: _MooTransport, string: String)?
    var transportDidReceiveStringReceivedInvocations: [(transport: _MooTransport, string: String)] = []
    var transportDidReceiveStringClosure: ((_MooTransport, String) -> Void)?

    func transport(_ transport: _MooTransport, didReceiveString string: String) {
        transportDidReceiveStringCallsCount += 1
        transportDidReceiveStringReceivedArguments = (transport: transport, string: string)
        transportDidReceiveStringReceivedInvocations.append((transport: transport, string: string))
        transportDidReceiveStringClosure?(transport, string)
    }

}
class _AsyncSocketMock: _AsyncSocket {




    //MARK: - beginReceiving

    var beginReceivingThrowableError: Error?
    var beginReceivingCallsCount = 0
    var beginReceivingCalled: Bool {
        return beginReceivingCallsCount > 0
    }
    var beginReceivingClosure: (() throws -> Void)?

    func beginReceiving() throws {
        if let error = beginReceivingThrowableError {
            throw error
        }
        beginReceivingCallsCount += 1
        try beginReceivingClosure?()
    }

    //MARK: - bind

    var bindToPortThrowableError: Error?
    var bindToPortCallsCount = 0
    var bindToPortCalled: Bool {
        return bindToPortCallsCount > 0
    }
    var bindToPortReceivedPort: UInt16?
    var bindToPortReceivedInvocations: [UInt16] = []
    var bindToPortClosure: ((UInt16) throws -> Void)?

    func bind(toPort port: UInt16) throws {
        if let error = bindToPortThrowableError {
            throw error
        }
        bindToPortCallsCount += 1
        bindToPortReceivedPort = port
        bindToPortReceivedInvocations.append(port)
        try bindToPortClosure?(port)
    }

    //MARK: - bind

    var bindToPortInterfaceThrowableError: Error?
    var bindToPortInterfaceCallsCount = 0
    var bindToPortInterfaceCalled: Bool {
        return bindToPortInterfaceCallsCount > 0
    }
    var bindToPortInterfaceReceivedArguments: (port: UInt16, interface: String?)?
    var bindToPortInterfaceReceivedInvocations: [(port: UInt16, interface: String?)] = []
    var bindToPortInterfaceClosure: ((UInt16, String?) throws -> Void)?

    func bind(toPort port: UInt16, interface: String?) throws {
        if let error = bindToPortInterfaceThrowableError {
            throw error
        }
        bindToPortInterfaceCallsCount += 1
        bindToPortInterfaceReceivedArguments = (port: port, interface: interface)
        bindToPortInterfaceReceivedInvocations.append((port: port, interface: interface))
        try bindToPortInterfaceClosure?(port, interface)
    }

    //MARK: - close

    var closeCallsCount = 0
    var closeCalled: Bool {
        return closeCallsCount > 0
    }
    var closeClosure: (() -> Void)?

    func close() {
        closeCallsCount += 1
        closeClosure?()
    }

    //MARK: - enableBroadcast

    var enableBroadcastThrowableError: Error?
    var enableBroadcastCallsCount = 0
    var enableBroadcastCalled: Bool {
        return enableBroadcastCallsCount > 0
    }
    var enableBroadcastReceivedFlag: Bool?
    var enableBroadcastReceivedInvocations: [Bool] = []
    var enableBroadcastClosure: ((Bool) throws -> Void)?

    func enableBroadcast(_ flag: Bool) throws {
        if let error = enableBroadcastThrowableError {
            throw error
        }
        enableBroadcastCallsCount += 1
        enableBroadcastReceivedFlag = flag
        enableBroadcastReceivedInvocations.append(flag)
        try enableBroadcastClosure?(flag)
    }

    //MARK: - enableReusePort

    var enableReusePortThrowableError: Error?
    var enableReusePortCallsCount = 0
    var enableReusePortCalled: Bool {
        return enableReusePortCallsCount > 0
    }
    var enableReusePortReceivedFlag: Bool?
    var enableReusePortReceivedInvocations: [Bool] = []
    var enableReusePortClosure: ((Bool) throws -> Void)?

    func enableReusePort(_ flag: Bool) throws {
        if let error = enableReusePortThrowableError {
            throw error
        }
        enableReusePortCallsCount += 1
        enableReusePortReceivedFlag = flag
        enableReusePortReceivedInvocations.append(flag)
        try enableReusePortClosure?(flag)
    }

    //MARK: - isClosed

    var isClosedCallsCount = 0
    var isClosedCalled: Bool {
        return isClosedCallsCount > 0
    }
    var isClosedReturnValue: Bool!
    var isClosedClosure: (() -> Bool)?

    func isClosed() -> Bool {
        isClosedCallsCount += 1
        if let isClosedClosure = isClosedClosure {
            return isClosedClosure()
        } else {
            return isClosedReturnValue
        }
    }

    //MARK: - joinMulticastGroup

    var joinMulticastGroupOnInterfaceThrowableError: Error?
    var joinMulticastGroupOnInterfaceCallsCount = 0
    var joinMulticastGroupOnInterfaceCalled: Bool {
        return joinMulticastGroupOnInterfaceCallsCount > 0
    }
    var joinMulticastGroupOnInterfaceReceivedArguments: (group: String, interface: String?)?
    var joinMulticastGroupOnInterfaceReceivedInvocations: [(group: String, interface: String?)] = []
    var joinMulticastGroupOnInterfaceClosure: ((String, String?) throws -> Void)?

    func joinMulticastGroup(_ group: String, onInterface interface: String?) throws {
        if let error = joinMulticastGroupOnInterfaceThrowableError {
            throw error
        }
        joinMulticastGroupOnInterfaceCallsCount += 1
        joinMulticastGroupOnInterfaceReceivedArguments = (group: group, interface: interface)
        joinMulticastGroupOnInterfaceReceivedInvocations.append((group: group, interface: interface))
        try joinMulticastGroupOnInterfaceClosure?(group, interface)
    }

    //MARK: - send

    var sendToHostPortWithTimeoutTagCallsCount = 0
    var sendToHostPortWithTimeoutTagCalled: Bool {
        return sendToHostPortWithTimeoutTagCallsCount > 0
    }
    var sendToHostPortWithTimeoutTagReceivedArguments: (data: Data, host: String, port: UInt16, timeout: TimeInterval, tag: Int)?
    var sendToHostPortWithTimeoutTagReceivedInvocations: [(data: Data, host: String, port: UInt16, timeout: TimeInterval, tag: Int)] = []
    var sendToHostPortWithTimeoutTagClosure: ((Data, String, UInt16, TimeInterval, Int) -> Void)?

    func send(_ data: Data, toHost host: String, port: UInt16, withTimeout timeout: TimeInterval, tag: Int) {
        sendToHostPortWithTimeoutTagCallsCount += 1
        sendToHostPortWithTimeoutTagReceivedArguments = (data: data, host: host, port: port, timeout: timeout, tag: tag)
        sendToHostPortWithTimeoutTagReceivedInvocations.append((data: data, host: host, port: port, timeout: timeout, tag: tag))
        sendToHostPortWithTimeoutTagClosure?(data, host, port, timeout, tag)
    }

    //MARK: - setDelegate

    var setDelegateDelegateQueueCallsCount = 0
    var setDelegateDelegateQueueCalled: Bool {
        return setDelegateDelegateQueueCallsCount > 0
    }
    var setDelegateDelegateQueueReceivedArguments: (delegate: _SocketDelegate?, delegateQueue: DispatchQueue?)?
    var setDelegateDelegateQueueReceivedInvocations: [(delegate: _SocketDelegate?, delegateQueue: DispatchQueue?)] = []
    var setDelegateDelegateQueueClosure: ((_SocketDelegate?, DispatchQueue?) -> Void)?

    func setDelegate(_ delegate: _SocketDelegate?, delegateQueue: DispatchQueue?) {
        setDelegateDelegateQueueCallsCount += 1
        setDelegateDelegateQueueReceivedArguments = (delegate: delegate, delegateQueue: delegateQueue)
        setDelegateDelegateQueueReceivedInvocations.append((delegate: delegate, delegateQueue: delegateQueue))
        setDelegateDelegateQueueClosure?(delegate, delegateQueue)
    }

}
class _MooTransportMock: _MooTransport {


    var delegate: MooTransportDelegate?


    //MARK: - close

    var closeCallsCount = 0
    var closeCalled: Bool {
        return closeCallsCount > 0
    }
    var closeClosure: (() -> Void)?

    func close() {
        closeCallsCount += 1
        closeClosure?()
    }

    //MARK: - resume

    var resumeCallsCount = 0
    var resumeCalled: Bool {
        return resumeCallsCount > 0
    }
    var resumeClosure: (() -> Void)?

    func resume() {
        resumeCallsCount += 1
        resumeClosure?()
    }

    //MARK: - send

    var sendDataCallsCount = 0
    var sendDataCalled: Bool {
        return sendDataCallsCount > 0
    }
    var sendDataReceivedData: Data?
    var sendDataReceivedInvocations: [Data] = []
    var sendDataClosure: ((Data) -> Void)?

    func send(data: Data) {
        sendDataCallsCount += 1
        sendDataReceivedData = data
        sendDataReceivedInvocations.append(data)
        sendDataClosure?(data)
    }

}
class _SoodMock: _Sood {


    var isStarted: Bool {
        get { return underlyingIsStarted }
        set(value) { underlyingIsStarted = value }
    }
    var underlyingIsStarted: Bool!
    var onMessage: ((SoodMessage) -> Void)?
    var onNetwork: (() -> Void)?


    //MARK: - query

    var queryServiceIdCallsCount = 0
    var queryServiceIdCalled: Bool {
        return queryServiceIdCallsCount > 0
    }
    var queryServiceIdReceivedServiceId: String?
    var queryServiceIdReceivedInvocations: [String] = []
    var queryServiceIdClosure: ((String) -> Void)?

    func query(serviceId: String) {
        queryServiceIdCallsCount += 1
        queryServiceIdReceivedServiceId = serviceId
        queryServiceIdReceivedInvocations.append(serviceId)
        queryServiceIdClosure?(serviceId)
    }

    //MARK: - start

    var startCallsCount = 0
    var startCalled: Bool {
        return startCallsCount > 0
    }
    var startClosure: (((() -> Void)?) -> Void)?

    func start(_ onStart: (() -> Void)?) {
        startCallsCount += 1
        startClosure?(onStart)
    }

}
class _URLSessionWebSocketTaskMock: _URLSessionWebSocketTask {


    var delegate: URLSessionTaskDelegate?


    //MARK: - cancel

    var cancelWithReasonCallsCount = 0
    var cancelWithReasonCalled: Bool {
        return cancelWithReasonCallsCount > 0
    }
    var cancelWithReasonReceivedArguments: (closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)?
    var cancelWithReasonReceivedInvocations: [(closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)] = []
    var cancelWithReasonClosure: ((URLSessionWebSocketTask.CloseCode, Data?) -> Void)?

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        cancelWithReasonCallsCount += 1
        cancelWithReasonReceivedArguments = (closeCode: closeCode, reason: reason)
        cancelWithReasonReceivedInvocations.append((closeCode: closeCode, reason: reason))
        cancelWithReasonClosure?(closeCode, reason)
    }

    //MARK: - receive

    var receiveCompletionHandlerCallsCount = 0
    var receiveCompletionHandlerCalled: Bool {
        return receiveCompletionHandlerCallsCount > 0
    }
    var receiveCompletionHandlerReceivedCompletionHandler: ((Result<URLSessionWebSocketTask.Message, Error>) -> Void)?
    var receiveCompletionHandlerReceivedInvocations: [((Result<URLSessionWebSocketTask.Message, Error>) -> Void)] = []
    var receiveCompletionHandlerClosure: ((@escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) -> Void)?

    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        receiveCompletionHandlerCallsCount += 1
        receiveCompletionHandlerReceivedCompletionHandler = completionHandler
        receiveCompletionHandlerReceivedInvocations.append(completionHandler)
        receiveCompletionHandlerClosure?(completionHandler)
    }

    //MARK: - resume

    var resumeCallsCount = 0
    var resumeCalled: Bool {
        return resumeCallsCount > 0
    }
    var resumeClosure: (() -> Void)?

    func resume() {
        resumeCallsCount += 1
        resumeClosure?()
    }

    //MARK: - send

    var sendCompletionHandlerCallsCount = 0
    var sendCompletionHandlerCalled: Bool {
        return sendCompletionHandlerCallsCount > 0
    }
    var sendCompletionHandlerReceivedArguments: (message: URLSessionWebSocketTask.Message, completionHandler: (Error?) -> Void)?
    var sendCompletionHandlerReceivedInvocations: [(message: URLSessionWebSocketTask.Message, completionHandler: (Error?) -> Void)] = []
    var sendCompletionHandlerClosure: ((URLSessionWebSocketTask.Message, @escaping (Error?) -> Void) -> Void)?

    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void) {
        sendCompletionHandlerCallsCount += 1
        sendCompletionHandlerReceivedArguments = (message: message, completionHandler: completionHandler)
        sendCompletionHandlerReceivedInvocations.append((message: message, completionHandler: completionHandler))
        sendCompletionHandlerClosure?(message, completionHandler)
    }

    //MARK: - sendPing

    var sendPingPongReceiveHandlerCallsCount = 0
    var sendPingPongReceiveHandlerCalled: Bool {
        return sendPingPongReceiveHandlerCallsCount > 0
    }
    var sendPingPongReceiveHandlerReceivedPongReceiveHandler: ((Error?) -> Void)?
    var sendPingPongReceiveHandlerReceivedInvocations: [((Error?) -> Void)] = []
    var sendPingPongReceiveHandlerClosure: ((@Sendable @escaping (Error?) -> Void) -> Void)?

    func sendPing(pongReceiveHandler: @Sendable @escaping (Error?) -> Void) {
        sendPingPongReceiveHandlerCallsCount += 1
        sendPingPongReceiveHandlerReceivedPongReceiveHandler = pongReceiveHandler
        sendPingPongReceiveHandlerReceivedInvocations.append(pongReceiveHandler)
        sendPingPongReceiveHandlerClosure?(pongReceiveHandler)
    }

}
