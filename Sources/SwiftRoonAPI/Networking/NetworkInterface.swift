//
//  NetInfo.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

struct NetworkInterface {

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

    static func getIFAddresses() -> [NetworkInterface] {
        var addresses = [NetworkInterface]()
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
