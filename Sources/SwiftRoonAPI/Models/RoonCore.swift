//
//  RoonCore.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/12/22.
//

import Foundation

class RoonCore: Codable {
    let coreID: String
    let displayName: String
    let displayVersion: String
    let token: String?
    let providedServices: [RoonServiceName]?
    let httpPort: UInt16?
    let extensionHost: String?
    unowned var moo: Moo!

    enum CodingKeys: String, CodingKey {
        case coreID = "core_id"
        case displayName = "display_name"
        case displayVersion = "display_version"
        case token = "token"
        case providedServices = "provided_services"
        case httpPort = "http_port"
        case extensionHost = "extension_host"
    }
}
