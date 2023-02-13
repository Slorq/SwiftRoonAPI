//
//  MooMessage.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/12/22.
//

import Foundation

enum MooVerb: String {
    case complete = "COMPLETE"
    case `continue` = "CONTINUE"
    case request = "REQUEST"
}

typealias MooName = String
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

enum MooHeaderName: String {
    case contentLength = "Content-Length"
    case contentType = "Content-Type"
    case logging = "Logging"
    case requestID = "Request-Id"
}

extension String {
    static var applicationJson: String { "application/json" }
}

struct MooMessage {
    var requestID: Int
    var verb: MooVerb
    var name: MooName
    var service: String?
    var headers: [MooHeaderName: String]
    var body: Data?

    init(requestID: Int,
         verb: MooVerb,
         name: MooName,
         service: String? = nil,
         headers: [MooHeaderName: String],
         body: Data? = nil) {
        self.requestID = requestID
        self.verb = verb
        self.name = name
        self.service = service
        self.headers = headers
        self.body = body
    }
}
