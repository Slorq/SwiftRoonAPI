//
//  TransportRequestName.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation
import SwiftRoonAPICore

struct TransportSubscriptionName {

    static var outputs: String { "outputs" }
    static var queue: String { "queue" }
    static var zones: String { "zones" }

}

struct TransportRequestName {

    static var changeSettings: String { .transport + "/change_settings" }
    static var changeVolume: String { .transport + "/change_volume" }
    static var control: String { .transport + "/control" }
    static var convenienceSwitch: String { .transport + "/convenience_switch" }
    static var getOutputs: String { .transport + "/get_outputs" }
    static var getZones: String { .transport + "/get_zones" }
    static var groupOutputs: String { .transport + "/group_outputs" }
    static var mute: String { .transport + "/mute" }
    static var muteAll: String { .transport + "/mute_all" }
    static var pauseAll: String { .transport + "/pause_all" }
    static var playFromHere: String { .transport + "/play_from_here" } 
    static var seek: String { .transport + "/seek" }
    static var standBy: String { .transport + "/standby" }
    static var toggleStandBy: String { .transport + "/toggle_standby" }
    static var transferZone: String { .transport + "/transfer_zone" }
    static var ungroupOutputs: String { .transport + "/ungroup_outputs" }

}
