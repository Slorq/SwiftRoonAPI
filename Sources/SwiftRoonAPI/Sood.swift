//
//  Sood.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 15/12/22.
//

import Combine
import Foundation
import SystemConfiguration
import Network

struct SoodMessage {
    let props: Props
    let from: From
    let type: String
}

extension SoodMessage {
    struct Props: Codable {
        let serviceId: String?
        let uniqueId: String?
        let httpPort: String?
        let tid: String?
        let tcpPort: String?
        let httpsPort: String?
        let displayVersion: String?
        let name: String?

        enum CodingKeys: String, CodingKey {
            case serviceId = "service_id"
            case uniqueId = "unique_id"
            case httpPort = "http_port"
            case tid = "_tid"
            case tcpPort = "tcp_port"
            case httpsPort = "https_port"
            case displayVersion = "display_version"
            case name = "name"
        }
    }
}

extension SoodMessage {
    struct From {
        var ip: String?
        var port: UInt16
    }
}

class Sood: NSObject {

    private let logger = Logger()
    private static let soodMulticastIP = "239.255.90.90"
    private static let soodPort: UInt16 = 9003
    private var interfaceSequence = 0
    private var interfaceTimer: AnyCancellable?
    private var multicast: [String: MulticastInterface] = [:]
    private var unicast: UnicastInterface = .init(sendSocket: nil, interfaceSequence: 0)
    private var onStart: (() -> Void)?
    var onMessage: ((SoodMessage) -> Void)?
    var onNetwork: (() -> Void)?

    func start(_ onStart: (() -> Void)?) {
        interfaceTimer = Timer.publish(every: 5, on: .current, in: .default)
            .autoconnect()
            .sink { [weak self] _ in self?.initSocket(onStart) }
        initSocket(onStart)
    }

    func stop() {
        logger.log("Stoping Sood")
        interfaceTimer = nil
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
        let interfaces = getIFAddresses()

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
                let socket = try Socket(port: 0, enableBroadcast: true)
                socket.onError = { [weak socket] error in
                    socket?.close()
                }
                socket.onClose = { [weak self] in
                    self?.unicast.sendSocket = nil
                }
                socket.onMessage = { [weak self] data, messageInfo in
                    guard let message = self?.parse(data: data, messageInfo: messageInfo) else { return }
                    self?.onMessage?(message)
                }
                unicast.sendSocket = socket
            } catch {
                assertionFailure("Something went wrong \(#function) - \(error)")
            }
        }

        if interfaceChange {
            onNetwork?()
        }
    }

    private func parse(data: Data, messageInfo: MessageInfo) -> SoodMessage? {
        guard var messageString = String(data: data, encoding: .utf8) else { return nil }

        var from = SoodMessage.From(ip: messageInfo.address, port: messageInfo.port)
        guard messageString.droppingPrefix(4) == "SOOD" else { return nil }
        guard messageString.droppingPrefix(1) == "\u{02}" else { return nil }
        let type = messageString.droppingPrefix(1)

        var propsDict: [String: String] = [:]
        while !messageString.isEmpty {
            guard let nameLength = [UInt8](messageString.droppingPrefix(1).utf8).first else {
                return nil
            }
            guard messageString.count >= nameLength else {
                return nil
            }
            let name = messageString.droppingPrefix(Int(nameLength))

            let rawValueLength = [UInt8](messageString.droppingPrefix(2).utf8)
            guard rawValueLength.count == 2,
                  let firstValueLength = rawValueLength.first,
                  let secondValueLength = rawValueLength.last else {
                return nil
            }

            let valueLength = (Int(firstValueLength) << 8) | Int(secondValueLength)
            let value: String
            if valueLength == 65535 {
                return nil
            } else if valueLength == 0 {
                value = ""
            } else {
                guard messageString.count >= valueLength else { return nil }
                value = messageString.droppingPrefix(valueLength)
            }

            if name == "_replyaddr" {
                from.ip = value
            } else if name == "_replyport", let port = [UInt16](value.utf16).first {
                from.port = port
            }

            propsDict[name] = value
        }

        do {
            let jsonProps = try JSONEncoder().encode(propsDict)
            let props = try JSONDecoder().decode(SoodMessage.Props.self, from: jsonProps)
            return .init(props: props, from: from, type: type)
        } catch {
            assertionFailure("something went wrong \(#function) - \(error)")
            return nil
        }
    }

    private func listenInterface(netInfo: NetInfo) -> Bool {
        guard !netInfo.ip.isEmpty else { return false }

        let interface = multicast[netInfo.ip] ?? MulticastInterface(interfaceSequence: interfaceSequence)
        interface.interfaceSequence = interfaceSequence
        var newInterface = false

        if interface.receiveSocket == nil {
            newInterface = true
            do {
                let socket = try Socket(port: Sood.soodPort,
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
                    guard let message = self?.parse(data: data, messageInfo: messageInfo) else { return }
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
                let socket = try Socket(port: 0,
                                        address: netInfo.ip,
                                        enableBroadcast: true)
                socket.onError = { [weak socket] error in
                    socket?.close()
                }
                socket.onClose = { [weak interface] in
                    interface?.sendSocket = nil
                }
                socket.onMessage = { [weak self] data, messageInfo in
                    guard let message = self?.parse(data: data, messageInfo: messageInfo) else { return }
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

    func getIFAddresses() -> [NetInfo] {
        var addresses = [NetInfo]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee

            guard let net = ptr.pointee.ifa_netmask?.pointee else { continue }

            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) { //  || addr.sa_family == UInt8(AF_IN) -> for IPv6

                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let getHostname = getnameinfo(ptr.pointee.ifa_addr,
                                                  socklen_t(addr.sa_len),
                                                  &hostname,
                                                  socklen_t(hostname.count),
                                                  nil,
                                                  socklen_t(0),
                                                  NI_NUMERICHOST)
                    getnameinfo(ptr.pointee.ifa_netmask,
                                socklen_t(net.sa_len),
                                &netmaskName,
                                socklen_t(netmaskName.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    if (getHostname == 0) {
                        let address = String(cString: hostname)
                        let mask = String(cString: netmaskName)
                        addresses.append(.init(ip: address, netmask: mask))
                    }
                }
            }
        }

        freeifaddrs(ifaddr)
        return addresses
    }

}

struct NetInfo {
    let ip: String
    let netmask: String

    var cidr: Int {
        var cidr = 0
        for number in binaryRepresentation(netmask) {
            let numberOfOnes = number.components(separatedBy: "1").count - 1
            cidr += numberOfOnes
        }
        return cidr
    }

    // Network Address
    var network: String {
        return bitwise(&, net1: ip, net2: netmask)
    }

    // Broadcast Address
    var broadcast: String {
        let inverted_netmask = bitwise(~, net1: netmask)
        let broadcast = bitwise(|, net1: network, net2: inverted_netmask)
        return broadcast
    }

    private func binaryRepresentation(_ s: String) -> [String] {
        var result: [String] = []
        for numbers in s.split(separator: ".") {
            if let intNumber = numbers.toInt() {
                if let binary = String(intNumber, radix: 2).toInt() {
                    result.append(NSString(format: "%08d", binary) as String)
                }
            }
        }
        return result
    }

    private func bitwise(_ op: (UInt8,UInt8) -> UInt8, net1: String, net2: String) -> String {
        let net1numbers = net1.toInts()
        let net2numbers = net2.toInts()
        var result = ""
        for i in 0..<net1numbers.count {
            result += "\(op(net1numbers[i],net2numbers[i]))"
            if i < (net1numbers.count-1) {
                result += "."
            }
        }
        return result
    }

    private func bitwise(_ op: (UInt8) -> UInt8, net1: String) -> String {
        let net1numbers = net1.toInts()
        var result = ""
        for i in 0..<net1numbers.count {
            result += "\(op(net1numbers[i]))"
            if i < (net1numbers.count-1) {
                result += "."
            }
        }
        return result
    }
}

extension Substring {
    func toInt() -> Int? {
        Int(self)
    }
}

extension String {
    func toInt() -> Int? {
        Int(self)
    }

    func toInts() -> [UInt8] {
        split(separator: ".").map{UInt8(Int($0)!)}
    }
}

class MulticastInterface {
    var sendSocket: Socket?
    var receiveSocket: Socket?
    var interfaceSequence: Int
    var subscriptions: Set<AnyCancellable> = []
    var broadcast: String?

    init(sendSocket: Socket? = nil, receiveSocket: Socket? = nil, interfaceSequence: Int, broadcast: String? = nil) {
        self.sendSocket = sendSocket
        self.receiveSocket = receiveSocket
        self.interfaceSequence = interfaceSequence
        self.broadcast = broadcast
    }
}

class UnicastInterface {
    var sendSocket: Socket?
    let interfaceSequence: Int
    var subscriptions: Set<AnyCancellable> = []

    init(sendSocket: Socket? = nil, interfaceSequence: Int) {
        self.sendSocket = sendSocket
        self.interfaceSequence = interfaceSequence
    }
}

extension String {
    mutating func droppingPrefix(_ k: Int) -> String {
        let prefix = prefix(k)
        droppingFirst(k)
        return String(prefix)
    }

    mutating func droppingFirst(_ k: Int) {
        self = String(dropFirst(k))
    }
}
