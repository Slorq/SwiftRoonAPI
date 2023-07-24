//
//  ZoneSeek.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

import Foundation

public enum SeekHow: String, Codable {

    case absolute
    case relative

}

struct ZoneSeekRequest: Codable {

    let zoneOrOutputID: String
    let how: SeekHow
    let seconds: Double

    enum CodingKeys: String, CodingKey {
        case zoneOrOutputID = "zone_or_output_id"
        case how
        case seconds
    }

}
