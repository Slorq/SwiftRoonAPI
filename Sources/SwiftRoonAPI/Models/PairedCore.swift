//
//  PairedCore.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

struct PairedCore: Codable {

    let coreID: String

    enum CodingKeys: String, CodingKey {
        case coreID = "paired_core_id"
    }

}
