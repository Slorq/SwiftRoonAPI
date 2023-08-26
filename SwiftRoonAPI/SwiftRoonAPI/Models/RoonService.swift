//
//  RoonService.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation
import SwiftRoonAPICore

open class RoonService {

    private(set) var name: String
    private var serviceSubscriptionHandlers: [String: SubscriptionHandlers]

    public init(name: String) {
        self.name = name
        self.serviceSubscriptionHandlers = .init()
    }

    func handler(subservice name: String,
                 mooID: Int,
                 subscriptionKey: String) -> SubscriptionMessageHandler? {
        serviceSubscriptionHandlers[name]?.handler(mooID: mooID, subscriptionKey: subscriptionKey)
    }

    func sendContinueAll(moo: _Moo, subservice: String, name: String, body: Data?) {
        guard let subservice = serviceSubscriptionHandlers[subservice]?.handlers() else {
            return
        }

        subservice.forEach { _, subscriptionHandlers in
            subscriptionHandlers.forEach({ _, subscriptionHandler in
                subscriptionHandler.sendContinue(moo, name, body, subscriptionHandler.message)
            })
        }
    }

    func register(handler: SubscriptionMessageHandler,
                  subserviceName name: String,
                  mooID: Int,
                  subscriptionKey: String) {
        if serviceSubscriptionHandlers[name] == nil {
            serviceSubscriptionHandlers[name] = .init()
        }

        serviceSubscriptionHandlers[name]?.register(handler: handler, mooID: mooID, subscriptionKey: subscriptionKey)
    }

    func remove(subserviceName name: String, mooID: Int, subscriptionKey: String) {
        serviceSubscriptionHandlers[name]?.removeHandler(for: mooID, subscriptionKey: subscriptionKey)
    }

    func remove(subserviceName name: String, mooID: Int) {
        serviceSubscriptionHandlers[name]?.removeHandlers(for: mooID)
    }
}

private class SubscriptionHandlers {

    private var registeredHandlers: [Int: [String: SubscriptionMessageHandler]] = [:]

    func handlers() -> [Int: [String: SubscriptionMessageHandler]]? {
        registeredHandlers
    }

    func handler(mooID: Int, subscriptionKey: String) -> SubscriptionMessageHandler? {
        registeredHandlers[mooID]?[subscriptionKey]
    }

    func register(handler: SubscriptionMessageHandler,
                  mooID: Int,
                  subscriptionKey: String) {
        if registeredHandlers[mooID] == nil {
            registeredHandlers[mooID] = [:]
        }

        registeredHandlers[mooID]?[subscriptionKey] = handler
    }

    func removeHandler(for mooID: Int, subscriptionKey: String) {
        registeredHandlers[mooID]?[subscriptionKey] = nil
    }

    func removeHandlers(for mooID: Int) {
        registeredHandlers[mooID] = nil
    }
}
