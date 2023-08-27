//
//  SubscriptionBodyMocks.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

import Foundation
@testable import SwiftRoonAPI

extension SubscriptionBody {

    static func makeEncoded() throws -> Data? {
        SubscriptionBody(subscriptionKey: "1").jsonEncoded()
    }

}
