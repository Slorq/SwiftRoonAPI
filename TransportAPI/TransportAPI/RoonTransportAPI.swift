//
//  RoonCore+Extensions.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 29/01/23.
//

import Foundation
import SwiftLogger
import SwiftRoonAPI
import SwiftRoonAPICore

fileprivate struct RoonCoreAssociatedKeys {
    static var transport: UInt8 = 0
}

extension RoonServiceName {
    static let transport = "com.roonlabs.transport:2"
}

public class RoonTransportAPI: RoonService {

    public convenience init() {
        self.init(name: .transport)
    }

}

extension RoonCore {

    private static let logger = Logger()

    /**
     * Mute/unmute all zones (that are mutable).
     * @param {('mute'|'unmute')} how - The action to take
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func muteAll(_ how: MuteHow) async -> Bool {
        let muteRequest = MuteRequest(how: how)
        let body = muteRequest.jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.muteAll, body: body)
        return message?.name == .success
    }

    /**
     * Pause all zones.
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func pauseAll() async -> Bool {
        await sendRequest(name: TransportRequestName.pauseAll)?.name == .success
    }

    /**
     * Standby an output.
     *
     * @param {Output} output - The output to put into standby
     * @param {object} opts - Options. If none, specify empty object ({}).
     * @param {string} [opts.control_key] - The <tt>control_key</tt> that identifies the <tt>source_control</tt> that is to be put into standby. If omitted, then all source controls on this output that support standby will be put into standby.
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func standBy(output: RoonOutput, options: [String: String]) async -> Bool {
        var options = options
        options["output_id"] = output.id
        let message = await sendRequest(name: TransportRequestName.standBy, body: options.jsonEncoded())
        return message?.name == .success
    }

    /**
     * Toggle the standby state of an output.
     *
     * @param {Output} output - The output that should have its standby state toggled.
     * @param {object} opts - Options. If none, specify empty object ({}).
     * @param {string} [opts.control_key] - The <tt>control_key</tt> that identifies the <tt>source_control</tt> that is to have its standby state toggled.
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func toggleStandBy(output: RoonOutput, options: [String: String]) async -> Bool {
        var options = options
        options["output_id"] = output.id
        let message = await sendRequest(name: TransportRequestName.toggleStandBy, body: options.jsonEncoded())
        return message?.name == .success
    }

    /**
     * Cconvenience switch an output, taking it out of standby if needed.
     *
     * @param {Output} output - The output that should be convenience-switched.
     * @param {object} opts - Options. If none, specify empty object ({}).
     * @param {string} [opts.control_key] - The <tt>control_key</tt> that identifies the <tt>source_control</tt> that is to be switched. If omitted, then all controls on this output will be convenience switched.
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func convenienceSwitch(output: RoonOutput, options: [String: String]) async -> Bool {
        var options = options
        options["output_id"] = output.id
        let message = await sendRequest(name: TransportRequestName.convenienceSwitch, body: options.jsonEncoded())
        return message?.name == .success
    }

    /**
     * Mute/unmute an output.
     * @param {Output} output - The output to mute.
     * @param {('mute'|'unmute')} how - The action to take
     */
    public func mute(output: RoonOutput, how: MuteHow) async -> Bool {
        let body = MuteOutputRequest(outputID: output.id, how: how).jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.mute, body: body)
        return message?.name == .success
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
    public func changeVolume(output: RoonOutput, how: ChangeVolumeHow, value: Double) async -> Bool {
        let body = ChangeVolumeRequest(outputID: output.id, how: how, value: value).jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.changeVolume, body: body)
        return message?.name == .success
    }

    /**
     * Seek to a time position within the now playing media
     * @param {Zone|Output} zone - The zone or output
     * @param {('relative'|'absolute')} how - How to interpret the target seek position
     * @param {number} seconds - The target seek position
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func seek(identifiable: RoonIdentifiable, how: SeekHow, seconds: Double) async -> Bool {
        let zoneSeek = ZoneSeekRequest(zoneOrOutputID: identifiable.id, how: how, seconds: seconds)
        let body = zoneSeek.jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.seek, body: body)
        return message?.name == .success
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
    public func control(identifiable: RoonIdentifiable, control: RoonControl) async -> Bool {
        let zoneControl = ZoneControl(zoneOrOutputID: identifiable.id, control: control)
        let body = zoneControl.jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.control, body: body)
        return message?.name == .success
    }

    /**
     * Transfer the current queue from one zone to another
     *
     * @param {Zone|Output} fromzone - The source zone or output
     * @param {Zone|Output} tozone - The destination zone or output
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func transferZone(from source: RoonIdentifiable, to destination: RoonIdentifiable) async -> Bool {
        let request = TransferZoneRequest(sourceID: source.id, destinationID: destination.id)
        let body = request.jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.transferZone, body: body)
        return message?.name == .success
    }

    /**
     * Create a group of synchronized audio outputs
     *
     * @param {Output[]} outputs - The outputs to group. The first output's zone's queue is preserved.
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func groupOutputs(outputs: [RoonOutput]) async -> Bool {
        let outputIDs = outputs.map { $0.id }
        let request = GroupOutputsRequest(outputIDs: outputIDs)
        let body = request.jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.groupOutputs, body: body)
        return message?.name == .success
    }

    /**
     * Ungroup outputs previous grouped
     *
     * @param {Output[]} outputs - The outputs to ungroup.
     * @param {RoonApiTransport~resultcallback} [cb] - Called on success or error
     */
    public func ungroupOutputs(outputs: [RoonOutput]) async -> Bool {
        let outputIDs = outputs.map { $0.id }
        let request = GroupOutputsRequest(outputIDs: outputIDs)
        let body = request.jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.ungroupOutputs, body: body)
        return message?.name == .success
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
    public func changeSettings(identifiable: RoonIdentifiable, shuffle: Bool? = nil, autoRadio: Bool? = nil, loop: LoopSetting? = nil) async -> Bool {
        let settings: [String: AnyEncodable?] = [
            "auto_radio": autoRadio.toAnyCodable(),
            "loop": loop?.rawValue.toAnyCodable(),
            "shuffle": shuffle.toAnyCodable(),
            "zone_or_output_id": identifiable.id.toAnyCodable(),
        ]
        let body = settings.jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.changeSettings, body: body)
        return message?.name == .success
    }

    public func getZones() async -> [RoonZone] {
        let message = await sendRequest(name: TransportRequestName.getZones)
        guard let body = message?.body,
              let response = try? JSONDecoder.fromSnakeCase.decode(GetZonesResponse.self, from: body) else {
            return []
        }

        return response.zones
    }

    public func getOutputs() async -> [RoonOutput] {
        let message = await sendRequest(name: TransportRequestName.getOutputs)
        guard let body = message?.body,
              let response = try? JSONDecoder.fromSnakeCase.decode(GetOutputsResponse.self, from: body) else {
            return []
        }

        return response.outputs
    }

    public func subscribeZones(completion: @escaping ([RoonZone]) -> Void) {
        var zones: [String: RoonZone] = [:]
        subscribeHelper(serviceName: .transport,
                        requestName: TransportSubscriptionName.zones) { message in
            guard let message = message,
                  let data = message.body,
                  let response = try? JSONDecoder.fromSnakeCase.decode(SubscribeZonesResponse.self, from: data) else {
                completion([])
                return
            }

            switch message.name {
            case .subscribed:
                zones = response.zones?.reduce(into: [String: RoonZone](), { $0[$1.zoneId] = $1 }) ?? [:]
            case .changed:
                if let zonesRemoved = response.zonesRemoved {
                    zonesRemoved.forEach { zones[$0] = nil }
                }
                if let zonesAdded = response.zonesAdded {
                    zonesAdded.forEach { zones[$0.zoneId] = $0 }
                }
                if let zonesChanged = response.zonesChanged {
                    zonesChanged.forEach { zones[$0.zoneId] = $0 }
                }
                if let zonesSeekChanged = response.zonesSeekChanged {
                    zonesSeekChanged.forEach { zoneSeekChanged in
                        zones[zoneSeekChanged.zoneId]?.nowPlaying?.seekPosition = zoneSeekChanged.seekPosition ?? 0
                        zones[zoneSeekChanged.zoneId]?.queueTimeRemaining = zoneSeekChanged.queueTimeRemaining
                    }
                }
            case .unsubscribed:
                zones = [:]
            default:
                Self.logger.log("Unrecognized name \(message.name) - \(message.verb)")
                assertionFailure("Unrecognized name \(message.name) - \(message.verb)")
            }

            completion(Array(zones.values))
        }
    }

    public func subscribeOutputs(completion: @escaping ([RoonOutput]) -> Void) {
        subscribeHelper(serviceName: .transport,
                        requestName: TransportSubscriptionName.outputs) { message in
            guard let message = message,
                  let data = message.body,
                  let response = try? JSONDecoder.fromSnakeCase.decode(SubscribeOutputsResponse.self, from: data) else {
                completion([])
                return
            }

            completion(response.outputs)
        }
    }

    public func subscribeQueue(identifiable: RoonIdentifiable, maxItems: Int, completion: @escaping ([QueueItem]) -> Void) {
        let body = SubscribeQueueRequest(id: identifiable.id, maxItems: maxItems).jsonEncoded()
        subscribeHelper(serviceName: .transport,
                        requestName: TransportSubscriptionName.queue,
                        body: body) { message in
                guard let message = message,
                      let data = message.body,
                      let response = try? JSONDecoder.default.decode(SubscribeQueueResponse.self, from: data) else {
                    completion([])
                    return
                }

                completion(response.items)
        }
    }

    public func playFromHere(identifiable: RoonIdentifiable, queueItem: QueueItem) async -> Bool {
        let request = PlayFromHereRequest(identifiableID: identifiable.id, queueItemID: queueItem.id)
        let body = request.jsonEncoded()
        let message = await sendRequest(name: TransportRequestName.playFromHere, body: body)
        return message?.name == .success
    }

    public func zone(byZoneID zoneID: String) async -> RoonZone? {
        await getZones().first(where: { $0.id == zoneID })
    }

    public func zone(byOutputID outputID: String) async -> RoonZone? {
        await getZones().first(where: { $0.outputs.map({ $0.id }).contains(outputID) })
    }

    func zone(byObjectID objectID: String) async -> RoonZone? {
        if let zone = await zone(byZoneID: objectID) {
            return zone
        } else {
            return await zone(byOutputID: objectID)
        }
    }

}
