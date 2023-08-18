//
//  InterfacesProviderMock.swift
//  
//
//  Created by Alejandro Maya on 16/08/23.
//

import Foundation
@testable import SwiftRoonAPI

enum InterfacesProviderMock: _NetworkInterfacesProvider {

    static var interfaces: [NetworkInterface] = []

}
