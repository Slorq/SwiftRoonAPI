//
//  MooEncoder.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftLogger

class MooEncoder {

    private let logger = Logger()

    func encode(message: MooMessage) -> Data? {
        logger.log(level: .debug, "MooEncoder - encode - \(message)")
        let name = message.name
        let requestID = message.requestID
        let body = message.body
        let firstLine = "MOO/1 \(message.verb.rawValue) \(name)"

        let headersString = message.headers.map { "\($0.key.rawValue): \($0.value)" }
            .joined(separator: "\n")
        let message = ("\(firstLine)\n\(headersString)\n\n")
        var data = message.data(using: .utf8)!
        body.map { data.append($0) }
        return data
    }

}
