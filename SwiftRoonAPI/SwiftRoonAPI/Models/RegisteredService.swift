//
//  RegisteredService.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

public typealias RegisteredSubservices = [String: [Int: [String: SubscriptionMessageHandler]]]

public class RegisteredService {

    public var name: String?
    public var subservices: RegisteredSubservices

    public init(name: String? = nil, subservices: RegisteredSubservices = [:]) {
        self.name = name
        self.subservices = subservices
    }
}
