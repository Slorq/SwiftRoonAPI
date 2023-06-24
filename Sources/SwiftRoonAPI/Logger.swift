//
//  Logger.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 5/12/22.
//

import Foundation
import os.log

public enum LogLevel: Int, Comparable {

    case error
    case warning
    case info
    case debug
    
    var label: String {
        switch self {
        case .error   : return "[🚨 Error]"
        case .warning : return "[⚠️ Warning]"
        case .info    : return "[ℹ️ Info]"
        case .debug   : return "[🐛 Debug]"
        }
    }

    var osLogType: OSLogType {
        switch self {
        case .error:
            return .error
        default:
            return .info
        }
    }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public struct Logger {

    static var enabled = true
    public static var level = LogLevel.error

    func log(level: LogLevel = .debug,
             _ items: Any...,
             file: String = #file,
             function: String = #function,
             line: Int = #line ,
             separator: String = " ") {
    #if DEBUG
        guard Self.enabled, level <= Logger.level else { return }

        let shortFileName = file.components(separatedBy: "/").last ?? "---"

        let output = items.map {
            if let itm = $0 as? CustomStringConvertible {
                return "\(itm.description)"
            } else {
                return "\($0)"
            }
        }
            .joined(separator: separator)

        var msg = "\(level.label) \(shortFileName) - \(function) - line \(line)"
        if !output.isEmpty { msg += "\n\(output)" }

        if level == .error {
            assertionFailure("Error: \(msg)")
        }

        os_log("%{public}@", type: level.osLogType, msg)
    #endif
    }

}
