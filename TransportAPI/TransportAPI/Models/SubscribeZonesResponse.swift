//
//  SubscribeZonesResponse.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

struct SubscribeZonesResponse: Codable {

    let zones: [RoonZone]?
    let zonesAdded: [RoonZone]?
    let zonesChanged: [RoonZone]?
    let zonesRemoved: [String]?
    let zonesSeekChanged: [ZoneSeekChanged]?
    
}
