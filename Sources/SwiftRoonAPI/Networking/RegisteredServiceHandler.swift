//
//  RegisteredServiceHandler.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

struct RegisteredServiceHandler {

    func sendContinueAll(subtypes: RegisteredServiceSubtype, moo: Moo, subtype: String, name: String, body: Data?) {
        guard let subtype = subtypes[subtype] else {
            assertionFailure("Couldn't find subtype \(subtype)")
            return
        }

        subtype.forEach { _, value in
            value.forEach({ key, value2 in
                value2.sendContinue(moo, name, body, value2.message)
            })
        }
    }

    func sendCompleteAll(subtypes: RegisteredServiceSubtype, moo: Moo, subtype: String, name: String, body: Data?) {
        guard let subtype = subtypes[subtype] else {
            assertionFailure("Couldn't find subtype \(subtype)")
            return
        }

        subtype.forEach { _, value in
            value.forEach({ key, value2 in
                value2.sendComplete(moo, name, body, value2.message)
            })
        }
    }

}
