//
//  JSONEncoder.swift
//  
//
//  Created by Alejandro Maya on 8/07/23.
//

import Foundation

public extension JSONEncoder {

    static let `default` = JSONEncoder()

}

public struct AnyEncodable: Encodable {

    private let _encode: (Encoder) throws -> Void

    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

public extension Encodable {

    func toAnyCodable() -> AnyEncodable {
        AnyEncodable(self)
    }

}
