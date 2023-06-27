//
//  ZoneControl.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

import Foundation

struct ZoneControl: Codable {

    let zoneOrOutputID: String
    let control: RoonControl

    enum CodingKeys: String, CodingKey {
        case zoneOrOutputID = "zone_or_output_id"
        case control
    }

}
