//
//  RegisteredService.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

//public typealias RegisteredSubservices = [String: [Int: [String: SubscriptionMessageHandler]]]

public class RegisteredService {

    public private(set) var name: String?
    private var subservices: SubserviceRegistry

    public init(name: String? = nil) {
        self.name = name
        self.subservices = .init()
    }

    func handlers(for name: String) -> [Int: [String: SubscriptionMessageHandler]]? {
        subservices.registeredHandlers[name]
    }

    func register(handler: SubscriptionMessageHandler,
                  subscriptionName name: String,
                  mooID: Int,
                  subscriptionKey: String) {
        if subservices.registeredHandlers[name] == nil {
            subservices.registeredHandlers[name] = [:]
        }

        if subservices.registeredHandlers[name]?[mooID] == nil {
            subservices.registeredHandlers[name]?[mooID] = [:]
        }

        subservices.registeredHandlers[name]?[mooID]?[subscriptionKey] = handler
    }

    func remove(subserviceName name: String, mooID: Int, subscriptionKey: String) {
        subservices.registeredHandlers[name]?[mooID]?[subscriptionKey] = nil
    }

    func remove(subserviceName name: String, mooID: Int) {
        subservices.registeredHandlers[name]?[mooID] = nil
    }
}

class SubserviceRegistry {

    fileprivate var registeredHandlers: [String: [Int: [String: SubscriptionMessageHandler]]] = [:]

    public init() {
    }

    func handlers(for name: String) -> [Int: [String: SubscriptionMessageHandler]]? {
        registeredHandlers[name]
    }

    func register(handler: SubscriptionMessageHandler,
                  subscriptionName name: String,
                  mooID: Int,
                  subscriptionKey: String) {
        if registeredHandlers[name] == nil {
            registeredHandlers[name] = [:]
        }

        if registeredHandlers[name]?[mooID] == nil {
            registeredHandlers[name]?[mooID] = [:]
        }

        registeredHandlers[name]?[mooID]?[subscriptionKey] = handler
    }

    func remove(subserviceName name: String, mooID: Int, subscriptionKey: String) {
        registeredHandlers[name]?[mooID]?[subscriptionKey] = nil
    }

    func remove(subserviceName name: String, mooID: Int) {
        registeredHandlers[name]?[mooID] = nil
    }

}
