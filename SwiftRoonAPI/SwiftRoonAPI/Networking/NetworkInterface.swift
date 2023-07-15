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

    private func bitwise(_ op: (UInt8, UInt8) -> UInt8, net1: String, net2: String) -> String {
        let net1numbers = net1.intComponents()
        let net2numbers = net2.intComponents()
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
        let net1numbers = net1.intComponents()
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
