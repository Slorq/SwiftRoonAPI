//
//  RegisteredService.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

typealias RegisteredSubservices = [String: [Int: [String: SubscriptionMessageHandler]]]

public class RegisteredService {

    var name: String?
    var subservices: RegisteredSubservices

    init(name: String? = nil, subservices: RegisteredSubservices = [:]) {
        self.name = name
        self.subservices = subservices
    }
}
