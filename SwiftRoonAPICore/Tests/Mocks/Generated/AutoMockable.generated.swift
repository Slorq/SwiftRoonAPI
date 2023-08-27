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


@testable import SwiftRoonAPICore






















public class _MooMock: _Moo {

    public init() {}

    public var mooID: Int {
        get { return underlyingMooID }
        set(value) { underlyingMooID = value }
    }
    public var underlyingMooID: Int!
    public var core: RoonCore?


    //MARK: - sendRequest

    public var sendRequestNameBodyContentTypeCompletionCallsCount = 0
    public var sendRequestNameBodyContentTypeCompletionCalled: Bool {
        return sendRequestNameBodyContentTypeCompletionCallsCount > 0
    }
    public var sendRequestNameBodyContentTypeCompletionClosure: ((MooName, Data?, String?, ((MooMessage?) -> Void)?) -> Void)?

    public func sendRequest(name: MooName, body: Data?, contentType: String?, completion: ((MooMessage?) -> Void)?) {
        sendRequestNameBodyContentTypeCompletionCallsCount += 1
        sendRequestNameBodyContentTypeCompletionClosure?(name, body, contentType, completion)
    }

    //MARK: - subscribeHelper

    public var subscribeHelperServiceNameRequestNameBodyCompletionCallsCount = 0
    public var subscribeHelperServiceNameRequestNameBodyCompletionCalled: Bool {
        return subscribeHelperServiceNameRequestNameBodyCompletionCallsCount > 0
    }
    public var subscribeHelperServiceNameRequestNameBodyCompletionClosure: ((String, String, Data?, ((MooMessage?) -> Void)?) -> Void)?

    public func subscribeHelper(serviceName: String, requestName: String, body: Data?, completion: ((MooMessage?) -> Void)?) {
        subscribeHelperServiceNameRequestNameBodyCompletionCallsCount += 1
        subscribeHelperServiceNameRequestNameBodyCompletionClosure?(serviceName, requestName, body, completion)
    }

    //MARK: - sendContinue

    public var sendContinueBodyMessageCompletionCallsCount = 0
    public var sendContinueBodyMessageCompletionCalled: Bool {
        return sendContinueBodyMessageCompletionCallsCount > 0
    }
    public var sendContinueBodyMessageCompletionClosure: ((MooName, Data?, MooMessage, ((MooMessage?) -> Void)?) -> Void)?

    public func sendContinue(_ name: MooName, body: Data?, message: MooMessage, completion: ((MooMessage?) -> Void)?) {
        sendContinueBodyMessageCompletionCallsCount += 1
        sendContinueBodyMessageCompletionClosure?(name, body, message, completion)
    }

    //MARK: - sendComplete

    public var sendCompleteBodyMessageCompletionCallsCount = 0
    public var sendCompleteBodyMessageCompletionCalled: Bool {
        return sendCompleteBodyMessageCompletionCallsCount > 0
    }
    public var sendCompleteBodyMessageCompletionClosure: ((MooName, Data?, MooMessage, ((MooMessage?) -> Void)?) -> Void)?

    public func sendComplete(_ name: MooName, body: Data?, message: MooMessage, completion: ((MooMessage?) -> Void)?) {
        sendCompleteBodyMessageCompletionCallsCount += 1
        sendCompleteBodyMessageCompletionClosure?(name, body, message, completion)
    }

}
