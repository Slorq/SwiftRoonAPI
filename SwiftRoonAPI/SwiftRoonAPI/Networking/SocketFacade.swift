//
//  SocketFacade.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 26/01/23.
//

import CocoaAsyncSocket
import Foundation
import SwiftRoonAPICore

enum SocketError: Error {
    case unableToCreateSocket
}

protocol _AsyncSocket: AutoMockable {
    func beginReceiving() throws
    func bind(toPort port: UInt16) throws
    func bind(toPort port: UInt16, interface: String?) throws
    func close()
    func enableBroadcast(_ flag: Bool) throws
    func enableReusePort(_ flag: Bool) throws
    func isClosed() -> Bool
    func joinMulticastGroup(_ group: String, onInterface interface: String?) throws
    func send(_ data: Data, toHost host: String, port: UInt16, withTimeout timeout: TimeInterval, tag: Int)
    func setDelegate(_ delegate: _SocketDelegate?, delegateQueue: DispatchQueue?)
}

extension GCDAsyncUdpSocket: _AsyncSocket {}

typealias _SocketDelegate = GCDAsyncUdpSocketDelegate

class SocketFacade: NSObject {

    var onError: ((Error?) -> Void)?
    var onClose: (() -> Void)?
    var onMessage: ((Data, MessageInfo) -> Void)?
    private let socket: _AsyncSocket

    init(port: UInt16,
         address: String? = nil,
         enableBroadcast: Bool = false,
         enableReusePort: Bool = false,
         joinMulticastGroup multicastGroup: String? = nil,
         onInterface interface: String? = nil,
         socket: _AsyncSocket) throws {
        do {
            self.socket = socket
            super.init()
            socket.setDelegate(self, delegateQueue: .main)
            try socket.enableReusePort(enableReusePort)

            if let address {
                try socket.bind(toPort: port, interface: address)
            } else {
                try socket.bind(toPort: port)
            }

            if let multicastGroup {
                try socket.joinMulticastGroup(multicastGroup, onInterface: interface)
            }

            try socket.enableBroadcast(enableBroadcast)
            try socket.beginReceiving()
        } catch {
            throw SocketError.unableToCreateSocket
        }
    }

    func send(_ data: Data, toHost host: String, port: UInt16, withTimeout timeout: TimeInterval, tag: Int) {
        socket.send(data, toHost: host, port: port, withTimeout: timeout, tag: tag)
    }

    func close() {
        socket.close()
    }

    func isClosed() -> Bool {
        socket.isClosed()
    }

}

extension SocketFacade: GCDAsyncUdpSocketDelegate {

    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        onError?(error)
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        onError?(error)
    }

    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let messageInfo = MessageInfo(address: GCDAsyncUdpSocket.host(fromAddress: address),
                                      port: sock.localPort())
        onMessage?(data, messageInfo)
    }

    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        onClose?()
    }
}

#if DEBUG
extension SocketFacade {

    var testHooks: TestHooks {
        .init(socketFacade: self)
    }

    struct TestHooks {

        private let socketFacade: SocketFacade

        init(socketFacade: SocketFacade) {
            self.socketFacade = socketFacade
        }

        var socket: _AsyncSocket { socketFacade.socket }

    }

}
#endif
