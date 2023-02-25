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

    func ipAddresses() -> [String] {
#if os(watchOS)
        return ["WatchOS"]
#elseif os(macOS)
        let networkInterfaces = SCNetworkInterfaceCopyAll() as Array
        let scNetworkInterfaces: [SCNetworkInterface] = (networkInterfaces as? [SCNetworkInterface]) ?? []
        return scNetworkInterfaces.compactMap {
            guard let bsdName = SCNetworkInterfaceGetBSDName($0) else { return nil }
            return getIPAddress(for: bsdName as String)
        }
#elseif os(iOS)
        return getiOSAddress(for: .wifi).map({ [$0] }) ?? []
#else
        fatalError("Unsupported OS")
#endif
    }

    private func getIPAddress(for bsdName: String) -> String? {
        var address: String?

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
                if name == bsdName {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }

    #if os(iOS)
    enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
        //... case ipv4 = "ipv4"
        //... case ipv6 = "ipv6"
    }

    func getiOSAddress(for network: Network) -> String? {
        var address: String?

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
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
    #endif
}
