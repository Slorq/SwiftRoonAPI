//
//  TransportRequestName.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation
import SwiftRoonAPICore

struct TransportSubscriptionName {

    static var zones: String { "zones" }

}

struct TransportRequestName {

    static var changeVolume: String { .transport + "/change_volume" }
    static var control: String { .transport + "/control" }
    static var getOutputs: String { .transport + "/get_outputs" }
    static var getZones: String { .transport + "/get_zones" }
    static var mute: String { .transport + "/mute" }
    static var muteAll: String { .transport + "/mute_all" }
    static var pauseAll: String { .transport + "/pause_all" }
    static var seek: String { .transport + "/seek" }
    static var standBy: String { .transport + "/standby" }
    static var transferZone: String { .transport + "/transfer_zone" }

}
