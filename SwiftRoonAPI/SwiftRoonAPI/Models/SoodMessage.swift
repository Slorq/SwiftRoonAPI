//
//  SoodMessage.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

struct SoodMessage: Equatable {

    let props: Props
    let from: From
    let type: String

}

extension SoodMessage {

    struct Props: Codable, Equatable {
        let serviceId: String?
        let uniqueId: String?
        let httpPort: String?
        let tid: String?
        let tcpPort: String?
        let httpsPort: String?
        let displayVersion: String?
        let name: String?

        init(serviceId: String? = nil,
             uniqueId: String? = nil,
             httpPort: String? = nil,
             tid: String? = nil,
             tcpPort: String? = nil,
             httpsPort: String? = nil,
             displayVersion: String? = nil,
             name: String? = nil) {
            self.serviceId = serviceId
            self.uniqueId = uniqueId
            self.httpPort = httpPort
            self.tid = tid
            self.tcpPort = tcpPort
            self.httpsPort = httpsPort
            self.displayVersion = displayVersion
            self.name = name
        }

        enum CodingKeys: String, CodingKey {
            case serviceId = "service_id"
            case uniqueId = "unique_id"
            case httpPort = "http_port"
            case tid = "_tid"
            case tcpPort = "tcp_port"
            case httpsPort = "https_port"
            case displayVersion = "display_version"
            case name = "name"
        }
    }
}

extension SoodMessage {
    
    struct From: Equatable {
        var ip: String?
        var port: UInt16
    }
    
}
