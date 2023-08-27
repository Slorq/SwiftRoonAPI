//
//  RoonServiceSpecs.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation
import SwiftRoonAPICore

public typealias ServiceMethodHandlers = [String: (_Moo, MooMessage) -> Void]

public class Subscription {

    let subscribeName: String
    let unsubscribeName: String
    let start: (_Moo, MooMessage) -> Void
    let end: (() -> Void)?

    init(subscribeName: String,
         unsubscribeName: String,
         start: @escaping (_Moo, MooMessage) -> Void,
         end: (() -> Void)? = nil) {
        self.subscribeName = subscribeName
        self.unsubscribeName = unsubscribeName
        self.start = start
        self.end = end
    }
}
