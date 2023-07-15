//
//  String.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

public extension String {

    /// Drops the first k characters from the string and returns them
    mutating func droppingPrefix(_ k: Int) -> String {
        let prefix = prefix(k)
        droppingFirst(k)
        return String(prefix)
    }

    /// Drops the k first characters from the string
    mutating func droppingFirst(_ k: Int) {
        self = String(dropFirst(k))
    }

    func toInt() -> Int? {
        Int(self)
    }

    func intComponents(separator: String = ".") -> [UInt8] {
        split(separator: separator).map{UInt8(Int($0)!)}
    }
}
