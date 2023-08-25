//
//  File.swift
//  
//
//  Created by Alejandro Maya on 27/06/23.
//

import Foundation
@testable import SwiftRoonAPI

extension RoonExtensionCompleteDetails {
    
    static func makeEncoded() -> Data? {
        RoonExtensionCompleteDetails(displayName: "Display Name",
                                     displayVersion: "0.0.1",
                                     email: "test@mail.com",
                                     extensionID: "com.coffeeware.roonminiplayer",
                                     publisher: "Slorq",
                                     website: "https://github.com/Slorq/roon-mini-player")
        .jsonEncoded()
    }
    
}
