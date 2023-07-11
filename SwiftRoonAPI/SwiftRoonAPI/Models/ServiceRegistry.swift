//
//  ServiceRegistry.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

open class ServiceRegistry {

    public private(set) var services: [RegisteredService] = []

    public init(services: [RegisteredService]) {
        self.services = services
    }
}
