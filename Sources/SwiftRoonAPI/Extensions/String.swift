//
//  String.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

extension String {

    mutating func droppingPrefix(_ k: Int) -> String {
        let prefix = prefix(k)
        droppingFirst(k)
        return String(prefix)
    }

    mutating func droppingFirst(_ k: Int) {
        self = String(dropFirst(k))
    }

    func toInt() -> Int? {
        Int(self)
    }

    func toInts() -> [UInt8] {
        split(separator: ".").map{UInt8(Int($0)!)}
    }
}
