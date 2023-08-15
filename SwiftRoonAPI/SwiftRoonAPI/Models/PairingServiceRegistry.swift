//
//  PairingServiceRegistry.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftRoonAPICore

class PairingServiceRegistry: ServiceRegistry {
    let foundCore: (RoonCore) -> Void
    let lostCore: (RoonCore) -> Void

    init(services: [RegisteredService], foundCore: @escaping (RoonCore) -> Void, lostCore: @escaping (RoonCore) -> Void) {
        self.foundCore = foundCore
        self.lostCore = lostCore
        super.init(services: services)
    }
}
