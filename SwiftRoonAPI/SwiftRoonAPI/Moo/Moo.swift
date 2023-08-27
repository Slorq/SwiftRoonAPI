//
//  Moo.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 5/12/22.
//

import Foundation
import SwiftLogger
import SwiftRoonAPICore

internal class Moo: NSObject, _Moo {

    private static var counter = 0

    private var transport: _MooTransport
    private var requestID = 0
    private var subKey = 0
    private let logger = Logger()
    private var requestHandlers: [Int: (MooMessage?) -> Void] = [:]
    private let mooEncoder: MooEncoder
    private let mooDecoder: MooDecoder
    let mooID: Int
    var onOpen: ((Moo) -> Void)?
    var onClose: ((Moo) -> Void)?
    var onError: ((Moo, Error) -> Void)?
    var onMessage: ((Moo, MooMessage) -> Void)?
    var core: RoonCore? {
        didSet {
            core?.moo = self
        }
    }

    init(transport: _MooTransport) {
        Self.counter += 1
        self.mooID = Self.counter
        self.transport = transport
        self.mooEncoder = MooEncoder()
        self.mooDecoder = MooDecoder()

        super.init()

        self.transport.delegate = self
    }

    func connectWebSocket() {
        transport.resume()
    }

    func sendRequest(name: MooName, body: Data? = nil, contentType: String? = nil, completion: ((MooMessage?) -> Void)?) {
        let headers: [MooHeaderName: String] = contentType.map { [.contentType: $0] } ?? [:]
        let message = MooMessage(requestID: requestID,
                                 verb: .request,
                                 name: name,
                                 headers: headers,
                                 body: body)
        send(message: message, completion: completion)
    }

    func sendComplete(_ name: MooName = .success, body: Data? = nil, message: MooMessage, completion: ((MooMessage?) -> Void)? = nil) {
        let message = MooMessage(requestID: message.requestID,
                                 verb: .complete,
                                 name: name,
                                 headers: [:])
        send(message: message, completion: completion)
    }

    func sendContinue(_ name: MooName = .success, body: Data? = nil, message: MooMessage, completion: ((MooMessage?) -> Void)? = nil) {
        let message = MooMessage(requestID: message.requestID,
                                 verb: .continue,
                                 name: name,
                                 headers: [:])
        send(message: message, completion: completion)
    }

    func subscribeHelper(serviceName: String, requestName: String, body: Data? = nil, completion: ((MooMessage?) -> Void)?) {
        subKey += 1
        var jsonBody = body.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [String: Any] ?? [:]
        jsonBody["subscription_key"] = subKey
        let body = try? JSONSerialization.data(withJSONObject: jsonBody)
        let name = "\(serviceName)/subscribe_\(requestName)"
        sendRequest(name: name, body: body, contentType: nil, completion: completion)
    }

    func cleanUp() {
        requestHandlers.forEach { key, handler in
            handler(nil)
        }
        requestHandlers = [:]
    }

    func handleMessage(message: MooMessage) -> Bool {
        logger.log("Moo <- \(message.verb.rawValue) \(message.requestID) \(message.name)")
        if let handler = requestHandlers[message.requestID] {
            handler(message)
            if message.verb == .complete {
                requestHandlers[message.requestID] = nil
            }
            return true
        } else {
            return false
        }
    }

    func close() {
        transport.close()
    }

    private func send(message: MooMessage, completion: ((MooMessage?) -> Void)?) {
        logger.log("Moo -> sendMessage -> \(message.verb.rawValue) \(message.requestID) \(message.name)")

        var mutableMessage = message
        mutableMessage.headers[.requestID] = "\(message.requestID)"
        if let body = message.body {
            mutableMessage.headers[.contentType] = message.headers[.contentType] ?? .applicationJson
            mutableMessage.headers[.contentLength] = "\(body.count)"
        }

        if let data = mooEncoder.encode(message: mutableMessage) {
            transport.send(data: data)
            requestHandlers[requestID] = completion
            requestID += 1
        }
    }

}

extension Moo: MooTransportDelegate {

    func transportDidOpen(_ transport: _MooTransport) {
        logger.log("Moo - didOpen")
        onOpen?(self)
    }

    func transportDidClose(_ transport: _MooTransport) {
        logger.log("Moo - didClose")
        onClose?(self)
    }

    func transport(_ transport: _MooTransport, didReceiveError error: Error) {
        logger.log("Moo - error - \(error)")
        onError?(self, error)
    }

    func transport(_ transport: _MooTransport, didReceiveData data: Data) {
        do {
            let message = try mooDecoder.decode(data)
            onMessage?(self, message)
        } catch {
            onError?(self, error)
        }
    }

    func transport(_ transport: _MooTransport, didReceiveString string: String) {
        do {
            let message = try mooDecoder.decode(string)
            onMessage?(self, message)
        } catch {
            onError?(self, error)
        }
    }

}

protocol _MooTransport: AutoMockable {

    var delegate: MooTransportDelegate? { get set }

    func close()
    func resume()
    func send(data: Data)
}

#if DEBUG
extension Moo {

    var testHooks: TestHooks {
        TestHooks(self)
    }

    struct TestHooks {

        private let moo: Moo

        init(_ moo: Moo) {
            self.moo = moo
        }

        var requestHandlers: [Int: (MooMessage?) -> Void] { moo.requestHandlers }
        var requestID: Int { moo.requestID }
        var transport: _MooTransport { moo.transport }
    }
}
#endif
