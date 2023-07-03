//
//  MooMessage.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/12/22.
//

import Foundation

public enum MooVerb: String {
    case complete = "COMPLETE"
    case `continue` = "CONTINUE"
    case request = "REQUEST"
}

public typealias MooName = String
extension MooName {
    static var info: MooName { "com.roonlabs.registry:1/info" }
    static var invalidRequest: MooName { "InvalidRequest" }
    static var register: MooName { "com.roonlabs.registry:1/register" }
    static var registered: MooName { "Registered" }
    static var success: MooName { "Success" }
    static var subscribed: MooName = "Subscribed"
    static var changed: MooName = "Changed"
    static var unsubscribed: MooName = "Unsubscribed"
}

public enum MooHeaderName: String {
    case contentLength = "Content-Length"
    case contentType = "Content-Type"
    case logging = "Logging"
    case requestID = "Request-Id"
}

extension String {
    static var applicationJson: String { "application/json" }
}

public struct MooMessage: Equatable {
    public var requestID: Int
    public var verb: MooVerb
    public var name: MooName
    public var service: String?
    public var headers: [MooHeaderName: String]
    public var body: Data?

    init(requestID: Int,
         verb: MooVerb,
         name: MooName,
         service: String? = nil,
         headers: [MooHeaderName: String] = [:],
         body: Data? = nil) {
        self.requestID = requestID
        self.verb = verb
        self.name = name
        self.service = service
        self.headers = headers
        self.body = body
    }
}
