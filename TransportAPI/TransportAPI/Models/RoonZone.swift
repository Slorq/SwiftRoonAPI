//
//  RoonZone.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

public struct RoonZone: Codable, RoonIdentifiable, Equatable {
    public let displayName: String
    public let isNextAllowed: Bool
    public let isPauseAllowed: Bool
    public let isPlayAllowed: Bool
    public let isPreviousAllowed: Bool
    public let isSeekAllowed: Bool
    public var nowPlaying: NowPlaying?
    public let outputs: [RoonOutput]
    public let queueItemsRemaining: Double
    public var queueTimeRemaining: Double
    public let settings: Settings
    public let state: RoonState
    let zoneId: String
}

extension RoonZone {
    public var id: String { zoneId }
}

public extension RoonZone {

    struct NowPlaying: Codable, Equatable {
        public let artistImageKeys: [String]?
        public let imageKey: String?
        public let length: Double
        public let oneLine: DisplayLines
        public var seekPosition: Double?
        public let threeLine: DisplayLines
        public let twoLine: DisplayLines
    }

    struct Settings: Codable, Equatable {
        public let autoRadio: Bool
        public let loop: String
        public let shuffle: Bool
    }

}

public extension RoonZone.NowPlaying {

    struct DisplayLines: Codable, Equatable {
        public let line1: String?
        public let line2: String?
        public let line3: String?
    }

}
