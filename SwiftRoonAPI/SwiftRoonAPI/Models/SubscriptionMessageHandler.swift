//
//  SubscriptionMessageHandler.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftRoonAPICore

public class SubscriptionMessageHandler {

    public private(set) var message: MooMessage

    public init(message: MooMessage) {
        self.message = message
    }

    var sendComplete: (_Moo, String, Data?, MooMessage) -> Void = { moo, name, body, message in
        moo.sendComplete(name, body: body, message: message)
    }

    var sendContinue: (_Moo, String, Data?, MooMessage) -> Void = { moo, name, body, message in
        moo.sendContinue(name, body: body, message: message)
    }
}
