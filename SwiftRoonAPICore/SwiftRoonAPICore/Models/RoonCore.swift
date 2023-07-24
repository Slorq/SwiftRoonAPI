//
//  RoonCore.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/12/22.
//

import Foundation

public class RoonCore: Codable {

    public let coreID: String
    public let displayName: String
    public let displayVersion: String
    public let token: String?
    public let providedServices: [RoonServiceName]?
    public let httpPort: UInt16?
    public let extensionHost: String?
    public unowned var moo: Moo!

    #if DEBUG
    public init(coreID: String,
                displayName: String,
                displayVersion: String,
                token: String?,
                providedServices: [RoonServiceName]?,
                httpPort: UInt16?,
                extensionHost: String?,
                moo: Moo) {
        self.coreID = coreID
        self.displayName = displayName
        self.displayVersion = displayVersion
        self.token = token
        self.providedServices = providedServices
        self.httpPort = httpPort
        self.extensionHost = extensionHost
        self.moo = moo
    }
    #endif

    enum CodingKeys: String, CodingKey {
        case coreID = "core_id"
        case displayName = "display_name"
        case displayVersion = "display_version"
        case token = "token"
        case providedServices = "provided_services"
        case httpPort = "http_port"
        case extensionHost = "extension_host"
    }

    public func sendRequest(name: MooName, body: Data? = nil, contentType: String? = nil) async -> MooMessage? {
        await withCheckedContinuation { continuation in
            moo.sendRequest(name: name, body: body, contentType: contentType) {
                continuation.resume(returning: $0)
            }
        }
    }

    public func subscribeHelper(serviceName: String, requestName: String, body: Data? = nil, completion: ((MooMessage?) -> Void)?) {
        moo.subscribeHelper(serviceName: serviceName, requestName: requestName, body: body, completion: completion)
    }
}
