//
//  RoonExtensionDetails.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

public struct RoonExtensionDetails {

    let displayName: String
    let displayVersion: String
    let email: String
    let extensionID: String
    let publisher: String
    let website: String

    public init(displayName: String,
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
