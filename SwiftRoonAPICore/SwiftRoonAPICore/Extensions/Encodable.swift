//
//  Encodable.swift
//  
//
//  Created by Alejandro Maya on 8/07/23.
//

import Foundation

public extension Encodable {

    func jsonEncoded() -> Data? {
        do {
            return try JSONEncoder.default.encode(self)
        } catch {
            assertionFailure("Unhandled error \(error)")
            return nil
        }
    }

}
