//
//  RoonOptions.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

struct RoonOptions {

    let displayName: String
    let displayVersion: String
    let email: String
    let extensionID: String
    var optionalServices: [RoonService] = []
    var providedServices: [RoonService] = []
    let publisher: String
    var requiredServices: [RoonService] = []
    let website: String

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

}
