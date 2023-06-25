//
//  RoonServiceSpecs.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

public class RoonServiceSpecs {
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
