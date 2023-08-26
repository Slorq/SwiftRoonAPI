//
//  PairingServiceRegistry.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftRoonAPICore

class PairingService {

    let service: RoonService
    let foundCore: (RoonCore) -> Void
    let lostCore: (RoonCore) -> Void

    init(service: RoonService, foundCore: @escaping (RoonCore) -> Void, lostCore: @escaping (RoonCore) -> Void) {
        self.service = service
        self.foundCore = foundCore
        self.lostCore = lostCore
    }
}
