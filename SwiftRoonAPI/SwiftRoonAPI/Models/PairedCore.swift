//
//  PairedCore.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

public struct PairedCore: Codable {

    public let coreID: String

    public init(coreID: String) {
        self.coreID = coreID
    }

    enum CodingKeys: String, CodingKey {
        case coreID = "paired_core_id"
    }

}
