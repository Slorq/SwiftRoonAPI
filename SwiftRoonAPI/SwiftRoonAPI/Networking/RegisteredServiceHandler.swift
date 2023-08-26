//
//  RegisteredServiceHandler.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftRoonAPICore

struct RegisteredServiceHandler {

    static func sendContinueAll(service: RoonService, moo: _Moo, subservice: String, name: String, body: Data?) {
        guard let subservice = service.handlers(for: subservice) else {
            return
        }

        subservice.forEach { _, subscriptionHandlers in
            subscriptionHandlers.forEach({ _, subscriptionHandler in
                subscriptionHandler.sendContinue(moo, name, body, subscriptionHandler.message)
            })
        }
    }

}
