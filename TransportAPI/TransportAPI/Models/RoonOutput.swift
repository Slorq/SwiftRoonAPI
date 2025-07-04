//
//  RoonOutput.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

public struct RoonOutput: Codable, RoonIdentifiable, Equatable {
    public var id: String { outputId }
    let canGroupWithOutputIds: [String]
    let displayName: String
    let outputId: String
    let sourceControls: [SourceControl]
    let volume: Volume?
    let zoneId: String
}

extension RoonOutput {

    struct SourceControl: Codable, Equatable {
        let controlKey: String
        let displayName: String
        let status: String
        let supportsStandby: Bool
    }

    struct Volume: Codable, Equatable {
        let hardLimitMax: Double
        let hardLimitMin: Double
        let isMuted: Bool
        let max: Double
        let min: Double
        let softLimit: Double
        let step: Double
        let type: String
        let value: Double
    }
}
