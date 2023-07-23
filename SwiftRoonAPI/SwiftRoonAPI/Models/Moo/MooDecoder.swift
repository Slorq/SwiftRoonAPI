//
//  MooDecoder.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/12/22.
//

import Foundation
import SwiftLogger
import SwiftRoonAPICore

enum MooDecodeError: Error, Equatable {
    case emptyData
    case badFirstLine
    case badFormat(cause: String)
    case badHeaderLine
    case missingRequestID
    case unableToDelimitHeaders
    case unrecognizedData
    case unrecognizedHeader
    case unrecognizedName
    case unrecognizedVerb
}

class MooDecoder {

    private let logger = Logger()

    func decode(_ data: Data) throws -> MooMessage {
        guard !data.isEmpty else {
            logger.log("MOO: empty message received")
            throw MooDecodeError.emptyData
        }

        guard let dataString = String(data: data, encoding: .utf8) else {
            throw MooDecodeError.unrecognizedData
        }

        return try decode(dataString)
    }

    func decode(_ string: String) throws -> MooMessage {
        logger.log("MooDecoder - decode - \(string)")
        let lines = string.components(separatedBy: "\n")

        // First line
        let firstLineRegex = #/^MOO\/([0-9]+) ([A-Z]+) (.*)/#
        guard let matches = lines.first?.matches(of: firstLineRegex).first else {
            throw MooDecodeError.badFirstLine
        }

        let rawVerb = matches.output.2
        guard let verb = MooVerb(rawValue: rawVerb.toString()) else {
            throw MooDecodeError.unrecognizedVerb
        }

        let service: String?
        let name: String
        if verb == .request {
            let requestRegex = #/([^\/]+)\/(.*)/#
            guard let requestMatches = matches.output.3.matches(of: requestRegex).first else {
                throw MooDecodeError.badFirstLine
            }

            service = requestMatches.output.1.toString()
            name = requestMatches.output.2.toString()
        } else {
            service = nil
            name = matches.output.3.toString()
        }

        // Headers
        guard let endOfHeaders = lines.firstIndex(where: { $0.isEmpty }) else {
            throw MooDecodeError.unableToDelimitHeaders
        }

        let headers = try lines[1..<endOfHeaders].reduce(into: [MooHeaderName: String]()) { partialResult, line in
            let headerRegex = #/([^:]+): *(.*)/#
            guard let headerMatches = line.matches(of: headerRegex).first else {
                throw MooDecodeError.badHeaderLine
            }

            guard let headerName = MooHeaderName(rawValue: headerMatches.output.1.toString()) else {
                throw MooDecodeError.unrecognizedHeader
            }
            partialResult[headerName] = headerMatches.output.2.toString()
        }

        guard let requestID = headers[.requestID].flatMap({ Int($0) }) else {
            throw MooDecodeError.missingRequestID
        }

        // Body
        // TODO: Update to read from buffer instead of transforming data from/to string
        var body: Data?
        if lines.count > endOfHeaders + 1, !lines[endOfHeaders + 1].isEmpty {
            body = lines[endOfHeaders + 1].data(using: .utf8)
        }
        
        return .init(requestID: requestID, verb: verb, name: name, service: service, headers: headers, body: body)
    }

}
