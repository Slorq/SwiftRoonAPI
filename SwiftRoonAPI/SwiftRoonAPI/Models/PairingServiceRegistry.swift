//
//  PairingServiceRegistry.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftRoonAPICore

class PairingServiceRegistry {

    let services: [RegisteredService]
    let foundCore: (RoonCore) -> Void
    let lostCore: (RoonCore) -> Void

    init(services: [RegisteredService], foundCore: @escaping (RoonCore) -> Void, lostCore: @escaping (RoonCore) -> Void) {
        self.services = services
        self.foundCore = foundCore
        self.lostCore = lostCore
    }
}
