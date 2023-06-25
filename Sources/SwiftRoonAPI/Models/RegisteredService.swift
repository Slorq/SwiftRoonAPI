//
//  RegisteredService.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

public class RegisteredService {

    var name: String?
    var subtypes: [String: [Int: [String: SubscriptionMessageHandler]]]

    init(name: String? = nil, subtypes: [String : [Int: [String: SubscriptionMessageHandler]]] = [:]) {
        self.name = name
        self.subtypes = subtypes
    }

    func sendContinueAll(moo: Moo, subtype: String, name: String, body: Data?) {
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

    func sendCompleteAll(moo: Moo, subtype: String, name: String, body: Data?) {
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
