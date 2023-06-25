//
//  RegisteredService.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

typealias RegisteredServiceSubtype = [String: [Int: [String: SubscriptionMessageHandler]]]

public class RegisteredService {

    var name: String?
    var subtypes: RegisteredServiceSubtype

    init(name: String? = nil, subtypes: RegisteredServiceSubtype = [:]) {
        self.name = name
        self.subtypes = subtypes
    }
}
