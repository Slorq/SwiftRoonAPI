//
//  QueueItem.swift
//  
//
//  Created by Alejandro Maya on 24/07/23.
//

import Foundation

public struct QueueItem: Codable, Equatable {

    let id: Int
    let imageKey: String?
    let length: Int
    let oneLine: DisplayLines
    let threeLines: DisplayLines
    let twoLines: DisplayLines

    enum CodingKeys: String, CodingKey {
        case id = "queue_item_id"
        case imageKey = "image_key"
        case length = "length"
        case oneLine = "one_line"
        case threeLines = "three_line"
        case twoLines = "two_line"
    }

}
