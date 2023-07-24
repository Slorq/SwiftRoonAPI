//
//  MuteOutputRequest.swift
//  
//
//  Created by Alejandro Maya on 23/07/23.
//

import Foundation

struct MuteOutputRequest: Codable {

    let outputID: String
    let how: MuteHow

    enum CodingKeys: String, CodingKey {
        case outputID = "output_id"
        case how
    }

}
