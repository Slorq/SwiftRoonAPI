//
//  RoonCore.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/12/22.
//

import Foundation

public class RoonCore: Codable {

    public let coreID: String
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

    public func sendRequest(name: MooName, body: Data? = nil, contentType: String? = nil, completion: ((MooMessage?) -> Void)?) {
        moo.sendRequest(name: name, body: body, contentType: contentType, completion: completion)
    }

    public func subscribeHelper(serviceName: String, requestName: String, body: Data? = nil, completion: ((MooMessage?) -> Void)?) {
        moo.subscribeHelper(serviceName: serviceName, requestName: requestName, body: body, completion: completion)
    }
}
