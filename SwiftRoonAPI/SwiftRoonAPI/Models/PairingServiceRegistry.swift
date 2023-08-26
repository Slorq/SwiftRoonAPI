//
//  PairingServiceRegistry.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftRoonAPICore

class PairingServiceRegistry {

    let services: [RoonService]
    let foundCore: (RoonCore) -> Void
    let lostCore: (RoonCore) -> Void

    init(services: [RoonService], foundCore: @escaping (RoonCore) -> Void, lostCore: @escaping (RoonCore) -> Void) {
        self.services = services
        self.foundCore = foundCore
        self.lostCore = lostCore
    }
}
