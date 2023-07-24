//
//  SubscribeQueueRequest.swift
//  
//
//  Created by Alejandro Maya on 24/07/23.
//

import Foundation

struct SubscribeQueueRequest: Codable {

    let id: String
    let maxItems: Int

    enum CodingKeys: String, CodingKey {
        case id = "zone_or_output_id"
        case maxItems = "max_item_count"
    }

}
