//
//  RoonAuthorizationState.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

struct RoonAuthorizationState: Codable, Equatable {

    var tokens: [String: String]
    
}
