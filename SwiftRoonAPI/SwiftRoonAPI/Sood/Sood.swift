//
//  Sood.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 15/12/22.
//

import Combine
import Foundation
import Network
import SwiftLogger
import SystemConfiguration

class Sood: NSObject {

    private static let soodMulticastIP = "239.255.90.90"
    private static let soodPort: UInt16 = 9003

    private let interfacesProvider: _NetworkInterfacesProvider.Type
    private let logger = Logger()

    private let parser = SoodMessageParser()
    private var interfaceSequence = 0
    private var interfaceTimer: AnyCancellable?
    private var multicast: [String: MulticastInterface] = [:]
    private var unicast: UnicastInterface = .init(sendSocket: nil)

    var onMessage: ((SoodMessage) -> Void)?
    var onNetwork: (() -> Void)?

    init(interfacesProvider: _NetworkInterfacesProvider.Type = NetworkInterfacesProvider.self) {
        self.interfacesProvider = interfacesProvider
    }

    func start(_ onStart: (() -> Void)?) {
        interfaceTimer = Timer.publish(every: 5, on: .current, in: .default)
            .autoconnect()
            .sink { [weak self] _ in self?.initSocket(onStart) }
        initSocket(onStart)
    }

    func stop() {
        logger.log("Stoping Sood")
        interfaceTimer?.cancel()
        multicast.forEach { (key, value) in
            value.sendSocket?.close()
            value.receiveSocket?.close()
        }
        unicast.sendSocket?.close()
    }

    func query(serviceId: String) {
        self.query(params: ["query_service_id" : serviceId])
    }

    private func query(params: [String: String]) {
        var params = params
        params ["_tid"] = params["_tid"] ?? UUID().uuidString
        var message = "SOOD\u{02}Q"
        for (key, value) in params {
            let namelen = UInt8(key.count)
            let unicodeScalar = UnicodeScalar.init(namelen)
            message += "\(unicodeScalar)\(key)"
            
            if params.isEmpty {
                message += "\u{ff}\u{ff}"
            } else {
                let namelen = value.count
                message += "\(UnicodeScalar(namelen >> 8)!)"
                message += "\(UnicodeScalar(namelen & 0xff)!)"
                message += "\(value)"
            }
        }
        let data = message.data(using: .utf8)!

        for (_, interface) in multicast {
            guard let broadcast = interface.broadcast else { return }
            interface.sendSocket?.send(data, toHost: Sood.soodMulticastIP, port: Sood.soodPort, withTimeout: 10, tag: 1)
            interface.sendSocket?.send(data, toHost: broadcast, port: Sood.soodPort, withTimeout: 10, tag: 2)
        }

        unicast.sendSocket?.send(data, toHost: Sood.soodMulticastIP, port: Sood.soodPort, withTimeout: 10, tag: 3)
    }

    private func initSocket(_ onStart: (() -> Void)?) {
        logger.log("Init socket")
        interfaceSequence += 1
        var interfaceChange = false
        let interfaces = interfacesProvider.interfaces

        interfaces.forEach { interface in
            if listenInterface(netInfo: interface) {
                interfaceChange = true || interfaceChange
            }
        }

        for (key, value) in multicast {
            if value.interfaceSequence != interfaceSequence {
                multicast[key] = nil
                interfaceChange = true
            }
        }

        if unicast.sendSocket == nil {
            logger.log("Creating unicast")
            do {
                let socket = try SocketFacade(port: 0, enableBroadcast: true)
                socket.onError = { [weak socket] error in
                    socket?.close()
                }
                socket.onClose = { [weak self] in
                    self?.unicast.sendSocket = nil
                }
                socket.onMessage = { [weak self] data, messageInfo in
                    guard let message = self?.parser.parse(data, messageInfo: messageInfo) else { return }
                    self?.onMessage?(message)
                }
                unicast.sendSocket = socket
            } catch {
                assertionFailure("Something went wrong \(#function) - \(error)")
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onStart?()
        }
        if interfaceChange {
            onNetwork?()
        }
    }

    private func listenInterface(netInfo: NetworkInterface) -> Bool {
        guard !netInfo.ip.isEmpty else { return false }

        let interface = multicast[netInfo.ip] ?? MulticastInterface(interfaceSequence: interfaceSequence)
        interface.interfaceSequence = interfaceSequence
        var newInterface = false

        if interface.receiveSocket == nil {
            newInterface = true
            do {
                let socket = try SocketFacade(port: Sood.soodPort,
                                              enableReusePort: true,
                                              joinMulticastGroup: Sood.soodMulticastIP,
                                              onInterface: netInfo.ip)
                socket.onError = { [weak socket] error in
                    socket?.close()
                }
                socket.onClose = { [weak interface] in
                    interface?.receiveSocket = nil
                }
                socket.onMessage = { [weak self] data, messageInfo in
                    guard let message = self?.parser.parse(data, messageInfo: messageInfo) else { return }
                    self?.onMessage?(message)
                }
                interface.receiveSocket = socket
            } catch {
                assertionFailure("Something went wrong \(#function) - \(error)")
            }
        }

        if interface.sendSocket == nil {
            newInterface = true
            interface.broadcast = netInfo.broadcast
            do {
                let socket = try SocketFacade(port: 0,
                                        address: netInfo.ip,
                                        enableBroadcast: true)
                socket.onError = { [weak socket] error in
                    socket?.close()
                }
                socket.onClose = { [weak interface] in
                    interface?.sendSocket = nil
                }
                socket.onMessage = { [weak self] data, messageInfo in
                    guard let message = self?.parser.parse(data, messageInfo: messageInfo) else { return }
                    self?.onMessage?(message)
                }
                interface.sendSocket = socket
            } catch {
                assertionFailure("Something went wrong \(#function) - \(error)")
            }
        }

        multicast[netInfo.ip] = interface

        return newInterface
    }

}

#if DEBUG
extension Sood {

    var testHooks: TestHooks {
        .init(sood: self)
    }

    struct TestHooks {

        private let sood: Sood

        init(sood: Sood) {
            self.sood = sood
        }

        var multicast: [String: MulticastInterface] { sood.multicast }
        var unicast: UnicastInterface { sood.unicast }

    }

}
#endif
