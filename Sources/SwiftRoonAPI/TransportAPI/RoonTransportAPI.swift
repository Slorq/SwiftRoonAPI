//
//  RoonCore+Extensions.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation
import SwiftLogger

fileprivate struct RoonCoreAssociatedKeys {
    static var transport: UInt8 = 0
}

extension RoonServiceName {
    static let transport = "com.roonlabs.transport:2"
}

public class RoonTransportAPI: ServiceRegistry {

    public convenience init(roonAPI: RoonAPI) {
        self.init(services: [.init(name: .transport)])
    }

}

public enum SeekHow: String {
    case absolute
    case relative
}

extension RoonTransportAPI {

    public class TransportService {

        private let logger = Logger()
        private let core: RoonCore
        private var zones: [String: RoonZone] = [:]
        private static let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()

        fileprivate init(core: RoonCore) {
            self.core = core
        }

        /**
         * Mute/unmute all zones (that are mutable).
         * @param {('mute'|'unmute')} how - The action to take
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func muteAll() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Pause all zones.
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func pauseAll() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Standby an output.
         *
         * @param {Output} output - The output to put into standby
         * @param {object} opts - Options. If none, specify empty object ({}).
         * @param {string} [opts.control_key] - The <tt>control_key</tt> that identifies the <tt>source_control</tt> that is to be put into standby. If omitted, then all source controls on this output that support standby will be put into standby.
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func standBy() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Toggle the standby state of an output.
         *
         * @param {Output} output - The output that should have its standby state toggled.
         * @param {object} opts - Options. If none, specify empty object ({}).
         * @param {string} [opts.control_key] - The <tt>control_key</tt> that identifies the <tt>source_control</tt> that is to have its standby state toggled.
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func toggleStandBy() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Cconvenience switch an output, taking it out of standby if needed.
         *
         * @param {Output} output - The output that should be convenience-switched.
         * @param {object} opts - Options. If none, specify empty object ({}).
         * @param {string} [opts.control_key] - The <tt>control_key</tt> that identifies the <tt>source_control</tt> that is to be switched. If omitted, then all controls on this output will be convenience switched.
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func convenienceSwitch() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Mute/unmute an output.
         * @param {Output} output - The output to mute.
         * @param {('mute'|'unmute')} how - The action to take
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func mute() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Change the volume of an output. Grouped zones can have differently behaving
         * volume systems (dB, min/max, steps, etc..), so you have to change the volume
         * different for each of those outputs.
         *
         * @param {Output} output - The output to change the volume on.
         * @param {('absolute'|'relative'|'relative_step')} how - How to interpret the volume
         * @param {number} value - The new volume value, or the increment value or step
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func changeVolume() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Seek to a time position within the now playing media
         * @param {Zone|Output} zone - The zone or output
         * @param {('relative'|'absolute')} how - How to interpret the target seek position
         * @param {number} seconds - The target seek position
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        public func seek(identifiable: RoonIdentifiable, how: SeekHow, seconds: Double, completion: @escaping (MooMessage?) -> Void) {
            let body = "{\"zone_or_output_id\": \"\(identifiable.id)\", \"how\": \"\(how.rawValue)\", \"seconds\": \(seconds)}"
                .data(using: .utf8)!
            core.moo.sendRequest(name: .transport + "/seek", body: body, completion: completion)
        }

        /**
         * Execute a transport control on a zone.
         *
         * Be sure that **is_control_allowed** is true on your Zone before allowing the user to operate controls
         *
         *  Parameters:
         *  - { Zone | Output } zone - The zone or output
         *  - {('play'|'pause'|'playpause'|'stop'|'previous'|'next')} control - The control desired
         *  - {RoonApiTransport~resultcallback} [cb] - Called on success or error
         *
         * "play" - If paused or stopped, start playback
         * "pause" - If playing or loading, pause playback
         * "playpause" - If paused or stopped, start playback. If playing or loading, pause playback.
         * "stop" - Stop playback and release the audio device immediately
         * "previous" - Go to the start of the current track, or to the previous track
         * "next" - Advance to the next track
         *
         */
        public func control(identifiable: RoonIdentifiable, control: RoonControl, completion: ((MooMessage?) -> Void)?) {
            let body = "{\"zone_or_output_id\": \"\(identifiable.id)\", \"control\": \"\(control.rawValue)\"}"
                .data(using: .utf8)!
            core.moo.sendRequest(name: .transport + "/control", body: body, completion: completion)
        }

        /**
         * Transfer the current queue from one zone to another
         *
         * @param {Zone|Output} fromzone - The source zone or output
         * @param {Zone|Output} tozone - The destination zone or output
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func transferZone() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Create a group of synchronized audio outputs
         *
         * @param {Output[]} outputs - The outputs to group. The first output's zone's queue is preserved.
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func groupOutputs() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Ungroup outputs previous grouped
         *
         * @param {Output[]} outputs - The outputs to ungroup.
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func ungroupOutputs() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        /**
         * Change zone settings
         *
         * @param {Zone|Output} zone - The zone or output
         * @param {object} settings - The settings to change
         * @param {boolean} [settings.shuffle] - If present, sets shuffle mode to the specified value
         * @param {boolean} [settings.auto_radio] - If present, sets auto_radio mode to the specified value
         * @param {('loop'|'loop_one'|'disabled'|'next')} [settings.loop] - If present, sets loop mode to the specified value. 'next' will cycle between the settings.
         * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
         */
        func changeSettings() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        public func getZones(completion: (([RoonZone]) -> Void)?) {
            core.moo.sendRequest(name: .transport + "/get_zones") { message in
                guard let body = message?.body,
                      let response = try? Self.decoder.decode(GetZonesResponse.self, from: body) else {
                    completion?([])
                    return
                }

                completion?(response.zones)
            }
        }

        public func getOutputs(completion: (([RoonOutput]) -> Void)?) {
            core.moo.sendRequest(name: .transport + "/get_outputs") { message in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let body = message?.body,
                    let response = try? decoder.decode(GetOutputsResponse.self, from: body) else {
                    completion?([])
                    return
                }

                completion?(response.outputs)
            }
        }

        public func subscribeZones(completion: (([RoonZone]) -> Void)?) {
            core.moo.subscribeHelper(serviceName: .transport,
                                     requestName: TransportRequest.zones) { [weak self] message in
                guard let self,
                      let message = message,
                      let data = message.body,
                      let response = try? Self.decoder.decode(SubscribeZonesResponse.self, from: data) else {
                    completion?([])
                    return
                }

                switch message.name {
                case .subscribed:
                    self.zones = response.zones?.reduce(into: [String: RoonZone](), { $0[$1.zoneId] = $1 }) ?? [:]
                case .changed:
                    if let zonesRemoved = response.zonesRemoved {
                        zonesRemoved.forEach { self.zones[$0] = nil }
                    }
                    if let zonesAdded = response.zonesAdded {
                        zonesAdded.forEach { self.zones[$0.zoneId] = $0 }
                    }
                    if let zonesChanged = response.zonesChanged {
                        zonesChanged.forEach { self.zones[$0.zoneId] = $0 }
                    }
                    if let zonesSeekChanged = response.zonesSeekChanged {
                        zonesSeekChanged.forEach { zoneSeekChanged in
                            self.zones[zoneSeekChanged.zoneId]?.nowPlaying?.seekPosition = zoneSeekChanged.seekPosition ?? 0
                            self.zones[zoneSeekChanged.zoneId]?.queueTimeRemaining = zoneSeekChanged.queueTimeRemaining
                        }
                    }
                case .unsubscribed:
                    self.zones = [:]
                default:
                    self.logger.log("Unrecognized name \(message.verb)")
                    assertionFailure("Unrecognized name \(message.verb)")
                }

                completion?(Array(self.zones.values))
            }
        }

        func subscribeOutputs() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        func subscribeQueue() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        func playFromHere() {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        func zone(byZoneID zoneID: String) {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        func zone(byOutputID outputID: String) {
            logger.log(level: .error, "Not implemented \(#function)")
        }

        func zone(byObject objectID: String) {
            logger.log(level: .error, "Not implemented \(#function)")
        }

    }
}

extension RoonCore {

    public var transport: RoonTransportAPI.TransportService {
        .init(core: self)
    }

}
