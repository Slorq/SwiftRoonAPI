//
//  PlayFromHereRequest.swift
//  
//
//  Created by Alejandro Maya on 24/07/23.
//

import Foundation

struct PlayFromHereRequest: Codable {

    let identifiableID: String
    let queueItemID: Int

    enum CodingKeys: String, CodingKey {
        case identifiableID = "zone_or_output_id"
        case queueItemID = "queue_item_id"
    }

}
