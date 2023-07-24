//
//  File.swift
//  
//
//  Created by Alejandro Maya on 17/07/23.
//

import Foundation

public enum MuteHow: String, Codable {

    case mute
    case unmute

}

struct MuteRequest: Codable {

    let how: MuteHow

}
