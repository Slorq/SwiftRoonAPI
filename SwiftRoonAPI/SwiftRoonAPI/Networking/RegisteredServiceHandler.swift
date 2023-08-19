//
//  RegisteredServiceHandler.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftRoonAPICore

struct RegisteredServiceHandler {

    static func sendContinueAll(subservices: RegisteredSubservices, moo: _Moo, subservice: String, name: String, body: Data?) {
        guard let subservice = subservices[subservice] else {
            assertionFailure("Couldn't find subtype \(subservice)")
            return
        }

        subservice.forEach { _, subscriptionHandlers in
            subscriptionHandlers.forEach({ _, subscriptionHandler in
                subscriptionHandler.sendContinue(moo, name, body, subscriptionHandler.message)
            })
        }
    }

}
