//
//  ZoneSeekChanged.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

struct ZoneSeekChanged: Codable {
    let zoneId: String
    let queueTimeRemaining: Double
    let seekPosition: Double?
}
