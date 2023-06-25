//
//  SubscriptionHandler.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

class SubscriptionMessageHandler {

    var message: MooMessage

    init(message: MooMessage) {
        self.message = message
    }

    var sendComplete: (Moo, String, Data?, MooMessage) -> Void = { moo, name, body, message in
        moo.sendComplete(name, body: body, message: message)
    }

    var sendContinue: (Moo, String, Data?, MooMessage) -> Void = { moo, name, body, message in
        moo.sendContinue(name, body: body, message: message)
    }
}
