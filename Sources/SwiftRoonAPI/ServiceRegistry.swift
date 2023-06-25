//
//  ServiceRegistry.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

public class ServiceRegistry {

    var services: [RegisteredService] = []

    init(services: [RegisteredService]) {
        self.services = services
    }
}
