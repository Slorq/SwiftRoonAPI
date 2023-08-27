//
//  GroupOutputsRequest.swift
//  
//
//  Created by Alejandro Maya on 24/07/23.
//

import Foundation

struct GroupOutputsRequest: Codable {

    let outputIDs: [String]

    enum CodingKeys: String, CodingKey {
        case outputIDs = "output_ids"
    }

}
