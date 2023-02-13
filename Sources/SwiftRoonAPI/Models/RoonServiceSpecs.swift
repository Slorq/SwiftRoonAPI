//
//  RoonServiceSpecs.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

class RoonServiceSpecs {
    let subscriptions: [Subscription]
    var methods: [String: (Moo, MooMessage) -> Void] = [:]

    init(subscriptions: [Subscription] = [], methods: [String: (Moo, MooMessage) -> Void] = [:]) {
        self.subscriptions = subscriptions
        self.methods = methods
    }
}

extension RoonServiceSpecs {

    class Subscription {
        let subscribeName: String
        let unsubscribeName: String
        let start: (Moo, MooMessage) -> Void
        let end: (() -> Void)?

        init(subscribeName: String,
             unsubscribeName: String,
             start: @escaping (Moo, MooMessage) -> Void,
             end: (() -> Void)? = nil) {
            self.subscribeName = subscribeName
            self.unsubscribeName = unsubscribeName
            self.start = start
            self.end = end
        }
    }

}

class RegisteredService {
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

class ServiceRegistry {
    var services: [RegisteredService] = []

    init(services: [RegisteredService]) {
        self.services = services
    }
}

class PairingServiceRegistry: ServiceRegistry {
    let foundCore: (RoonCore) -> Void
    let lostCore: (RoonCore) -> Void

    init(services: [RegisteredService], foundCore: @escaping (RoonCore) -> Void, lostCore: @escaping (RoonCore) -> Void) {
        self.foundCore = foundCore
        self.lostCore = lostCore
        super.init(services: services)
    }
}

struct SubscriptionBody: Codable {
    let subscriptionKey: String
}

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
