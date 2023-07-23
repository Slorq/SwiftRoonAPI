//
//  TransportRequestName.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation

typealias TransportRequestName = String

extension TransportRequestName {
    static var zones: TransportRequestName { "zones" }
}

extension TransportRequestName {
    static var control: TransportRequestName { .transport + "/control" }
    static var getOutputs: TransportRequestName { .transport + "/get_outputs" }
    static var getZones: TransportRequestName { .transport + "/get_zones" }
    static var muteAll: TransportRequestName { .transport + "/mute_all" }
    static var pauseAll: TransportRequestName { .transport + "/pause_all" }
    static var seek: TransportRequestName { .transport + "/seek" }
}
