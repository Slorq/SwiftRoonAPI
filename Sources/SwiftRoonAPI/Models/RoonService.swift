//
//  RoonServiceName.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

typealias RoonServiceName = String

extension RoonServiceName {
    static let ping = "com.roonlabs.ping:1"
    static let pairing = "com.roonlabs.pairing:1"
}

struct RoonService {
    let name: RoonServiceName
    let specs: RoonServiceSpecs?

    init(name: RoonServiceName, specs: RoonServiceSpecs? = nil) {
        self.name = name
        self.specs = specs
    }
}
