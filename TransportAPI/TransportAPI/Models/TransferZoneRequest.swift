//
//  TransferZoneRequest.swift
//  
//
//  Created by Alejandro Maya on 24/07/23.
//

import Foundation

struct TransferZoneRequest: Codable {

    let sourceID: String
    let destinationID: String

    enum CodingKeys: String, CodingKey {
        case sourceID = "from_zone_or_output_id"
        case destinationID = "to_zone_or_output_id"
    }

}
