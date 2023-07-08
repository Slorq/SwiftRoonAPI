//
//  JSONDecoder.swift
//  
//
//  Created by Alejandro Maya on 8/07/23.
//

import Foundation

extension JSONDecoder {

    static let `default` = JSONDecoder()

    static let fromSnakeCase: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

}
