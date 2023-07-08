//
//  Encodable.swift
//  
//
//  Created by Alejandro Maya on 8/07/23.
//

import Foundation

extension Encodable {

    func jsonEncoded() throws -> Data {
        return try JSONEncoder.default.encode(self)
    }

}
