//
//  RoonZone.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

struct RoonZone: Codable {
    let displayName: String
    let isNextAllowed: Bool
    let isPauseAllowed: Bool
    let isPlayAllowed: Bool
    let isPreviousAllowed: Bool
    let isSeekAllowed: Bool
    var nowPlaying: NowPlaying?
    let outputs: [RoonOutput]
    let queueItemsRemaining: Double
    var queueTimeRemaining: Double
    let settings: Settings
    let state: RoonState
    let zoneId: String
}

extension RoonZone: RoonIdentifiable {
    var id: String { zoneId }
}

extension RoonZone {

    struct NowPlaying: Codable {
        let artistImageKeys: [String]
        let imageKey: String?
        let length: Double
        let oneLine: DisplayLines
        var seekPosition: Double?
        let threeLine: DisplayLines
        let twoLine: DisplayLines
    }

    struct Settings: Codable {
        let autoRadio: Bool
        let loop: String
        let shuffle: Bool
    }

}

extension RoonZone.NowPlaying {

    struct DisplayLines: Codable {
        let line1: String?
        let line2: String?
        let line3: String?
    }

}
