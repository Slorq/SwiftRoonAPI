//
//  File.swift
//  
//
//  Created by Alejandro Maya on 16/08/23.
//

import Foundation

struct SoodMessageParser {

    func parse(_ data: Data, messageInfo: MessageInfo) -> SoodMessage? {
        guard var messageString = String(data: data, encoding: .utf8) else { return nil }

        return parse(messageString, messageInfo: messageInfo)
    }

    func parse(_ string: String, messageInfo: MessageInfo) -> SoodMessage? {
        var messageString = string
        var from = SoodMessage.From(ip: messageInfo.address, port: messageInfo.port)
        guard messageString.droppingPrefix(4) == "SOOD" else { return nil }
        guard messageString.droppingPrefix(1) == "\u{02}" else { return nil }
        let type = messageString.droppingPrefix(1)

        var propsDict: [String: String] = [:]
        while !messageString.isEmpty {
            guard let nameLength = [UInt8](messageString.droppingPrefix(1).utf8).first else {
                return nil
            }
            guard messageString.count >= nameLength else {
                return nil
            }
            let name = messageString.droppingPrefix(Int(nameLength))

            let rawValueLength = [UInt8](messageString.droppingPrefix(2).utf8)
            guard rawValueLength.count == 2,
                  let firstValueLength = rawValueLength.first,
                  let secondValueLength = rawValueLength.last else {
                return nil
            }

            let valueLength = (Int(firstValueLength) << 8) | Int(secondValueLength)
            let value: String
            if valueLength == 65535 {
                return nil
            } else if valueLength == 0 {
                value = ""
            } else {
                guard messageString.count >= valueLength else { return nil }
                value = messageString.droppingPrefix(valueLength)
            }

            if name == "_replyaddr" {
                from.ip = value
            } else if name == "_replyport", let port = [UInt16](value.utf16).first {
                from.port = port
            }

            propsDict[name] = value
        }

        do {
            let jsonProps = try JSONEncoder.default.encode(propsDict)
            let props = try JSONDecoder.default.decode(SoodMessage.Props.self, from: jsonProps)
            return .init(props: props, from: from, type: type)
        } catch {
            assertionFailure("something went wrong \(#function) - \(error)")
            return nil
        }
    }

}
