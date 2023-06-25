//
//  SoodMessage.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

struct SoodMessage {
    let props: Props
    let from: From
    let type: String
}

extension SoodMessage {

    struct Props: Codable {
        let serviceId: String?
        let uniqueId: String?
        let httpPort: String?
        let tid: String?
        let tcpPort: String?
        let httpsPort: String?
        let displayVersion: String?
        let name: String?

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
    
    struct From {
        var ip: String?
        var port: UInt16
    }
}
