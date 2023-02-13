//
//  RoonState.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

enum RoonState: String, Codable {
    case playing
    case paused
    case loading
    case stopped
}
