//
//  ChangeVolume.swift
//  
//
//  Created by Alejandro Maya on 23/07/23.
//

import Foundation

public enum ChangeVolumeHow: String, Codable {

    case absolute = "absolute"
    case relative = "relative"
    case relativeStep = "relative_step"

}

struct ChangeVolumeRequest: Codable {

    let outputID: String
    let how: ChangeVolumeHow
    let value: Double

    enum CodingKeys: String, CodingKey {
        case outputID = "output_id"
        case how
        case value
    }

}
