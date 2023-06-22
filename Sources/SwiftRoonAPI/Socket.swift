//
//  Socket.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 26/01/23.
//

import CocoaAsyncSocket
import Foundation

enum SocketError: Error {
    case unableToCreateSocket
}

class Socket: NSObject {

    var onError: ((Error?) -> Void)?
    var onClose: (() -> Void)?
    var onMessage: ((Data, MessageInfo) -> Void)?
    private let socket: GCDAsyncUdpSocket
    private let address: String?
    private let port: UInt16

    init(port: UInt16,
         address: String? = nil,
         enableBroadcast: Bool = false,
         enableReusePort: Bool = false,
         joinMulticastGroup multicastGroup: String? = nil,
         onInterface interface: String? = nil) throws {
        do {
            self.address = address
            self.port = port
            let socket = GCDAsyncUdpSocket()
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

extension Socket: GCDAsyncUdpSocketDelegate {

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

struct MessageInfo {
    let address: String?
    let port: UInt16
}
