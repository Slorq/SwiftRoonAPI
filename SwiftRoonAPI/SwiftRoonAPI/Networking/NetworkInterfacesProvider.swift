//
//  NetworkInterfacesProvider.swift
//  
//
//  Created by Alejandro Maya on 25/02/23.
//

import Foundation
#if os(macOS)
import SystemConfiguration
#endif

struct NetworkInterfacesProvider {

    static var interfaces: [NetworkInterface] {
        #if os(watchOS)
            return ["WatchOS"]
        #elseif os(macOS)
            return getMacOSAddresses()
        #elseif os(iOS)
            return getiOSAddress(for: .wifi).map({ [$0] }) ?? []
        #else
            fatalError("Unsupported OS")
        #endif
    }
}

// MARK: MacOS

#if os(macOS)
extension NetworkInterfacesProvider {

    private static func getMacOSAddresses() -> [NetworkInterface] {
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

}
#endif

// MARK: iOS

#if os(iOS)
extension NetworkInterfacesProvider {

    enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
        //... case ipv4 = "ipv4"
        //... case ipv6 = "ipv6"
    }

    private static func getiOSAddress(for network: Network) -> String? {
        var address: NetworkInterface?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let getHostname = getnameinfo(interface.ifa_addr,
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname,
                                socklen_t(hostname.count),
                                nil,
                                socklen_t(0), NI_NUMERICHOST)
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
                        address = .init(ip: address, netmask: mask)
                    }
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }

}
#endif
