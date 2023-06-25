//
//  RoonConfig.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/12/22.
//

import Foundation

struct RoonAuthorizationState: Codable {

    var tokens: [String: String]
}

struct RoonConfig: Codable {
    
    var roonState: RoonAuthorizationState
    var pairedCoreID: String?
}
