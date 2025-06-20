//
//  RoonExtensionCompleteDetails.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation
import SwiftRoonAPICore

struct RoonExtensionCompleteDetails: Codable {

    let displayName: String
    let displayVersion: String
    let email: String
    let extensionID: String
    let publisher: String
    let website: String
    var optionalServices: [RoonServiceName] = []
    var providedServices: [RoonServiceName] = []
    var requiredServices: [RoonServiceName] = []
    var token: String?

    init(displayName: String,
         displayVersion: String,
         email: String,
         extensionID: String,
         publisher: String,
         website: String) {
        self.displayName = displayName
        self.displayVersion = displayVersion
        self.email = email
        self.extensionID = extensionID
        self.publisher = publisher
        self.website = website
    }

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case displayVersion = "display_version"
        case email = "email"
        case extensionID = "extension_id"
        case optionalServices = "optional_services"
        case providedServices = "provided_services"
        case publisher = "publisher"
        case requiredServices = "required_services"
        case token = "token"
        case website = "website"
    }

}

extension RoonExtensionCompleteDetails {
    
    init(details: RoonExtensionDetails) {
        displayName = details.displayName
        displayVersion = details.displayVersion
        email = details.email
        extensionID = details.extensionID
        publisher = details.publisher
        website = details.website
    }
}
