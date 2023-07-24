//
//  RoonTransportAPITests.swift
//  
//
//  Created by Alejandro Maya on 8/07/23.
//

@testable import RoonTransportAPI
import SwiftRoonAPICore
import TestsCommon
import XCTest

final class RoonTransportAPITests: XCTestCase {

    private var core: RoonCore!
    private var transportAPI: RoonTransportAPI!
    private var mooMock: MooMock!

    override func setUp() {
        super.setUp()
        mooMock = .init()
        core = .make(moo: mooMock)
    }

    func testMuteAll() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/mute_all")
            XCTAssertEqual(bodyString, "{\"how\":\"mute\"}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }

        // When
        let succeeded = await core.muteAll(.mute)

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testPauseAll() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            XCTAssertEqual(mooName, "com.roonlabs.transport:2/pause_all")
            XCTAssertNil(body)
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }

        // When
        let succeeded = await core.pauseAll()

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testStandBy() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/standby")
            XCTAssertEqual(bodyString, "{\"control_key\":\"ControlKey1\",\"output_id\":\"OutputID-1\"}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let output = RoonOutput.make()

        // When
        let succeeded = await core.standBy(output: output, options: ["control_key": "ControlKey1"])

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testToggleStandBy() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/toggle_standby")
            XCTAssertEqual(bodyString, "{\"control_key\":\"ControlKey1\",\"output_id\":\"OutputID-1\"}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let output = RoonOutput.make()

        // When
        let succeeded = await core.toggleStandBy(output: output, options: ["control_key": "ControlKey1"])

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testConvenienceSwitch() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/convenience_switch")
            XCTAssertEqual(bodyString, "{\"control_key\":\"ControlKey1\",\"output_id\":\"OutputID-1\"}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let output = RoonOutput.make()

        // When
        let succeeded = await core.convenienceSwitch(output: output, options: ["control_key": "ControlKey1"])

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testMute() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/mute")
            XCTAssertEqual(bodyString, "{\"how\":\"mute\",\"output_id\":\"OutputID-1\"}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let roonOutput = RoonOutput.make()

        // When
        let succeeded = await core.mute(output: roonOutput, how: .mute)

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testChangeVolume() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/change_volume")
            XCTAssertEqual(bodyString, "{\"how\":\"absolute\",\"output_id\":\"OutputID-1\",\"value\":50}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let roonOutput = RoonOutput.make()

        // When
        let succeeded = await core.changeVolume(output: roonOutput, how: .absolute, value: 50)

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testSeek() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/seek")
            XCTAssertEqual(bodyString, "{\"zone_or_output_id\":\"ZoneID-1\",\"how\":\"absolute\",\"seconds\":10}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let roonZone = RoonZone.make()

        // When
        let succeeded = await core.seek(identifiable: roonZone, how: .absolute, seconds: 10)

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testControl() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/control")
            XCTAssertEqual(bodyString, "{\"zone_or_output_id\":\"ZoneID-1\",\"control\":\"playpause\"}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let roonZone = RoonZone.make()

        // When
        let succeeded = await core.control(identifiable: roonZone, control: .playpause)

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testTransferZone() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/transfer_zone")
            XCTAssertEqual(bodyString, "{\"from_zone_or_output_id\":\"SourceZoneID\",\"to_zone_or_output_id\":\"DestinationZoneID\"}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let sourceZone = RoonZone.make(zoneId: "SourceZoneID")
        let destinationZone = RoonZone.make(zoneId: "DestinationZoneID")

        // When
        let succeeded = await core.transferZone(from: sourceZone, to: destinationZone)

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testGroupOutputs() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/group_outputs")
            XCTAssertEqual(bodyString, "{\"output_ids\":[\"OutputID-1\",\"OutputID-2\"]}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let output1 = RoonOutput.make(outputID: "OutputID-1")
        let output2 = RoonOutput.make(outputID: "OutputID-2")

        // When
        let succeeded = await core.groupOutputs(outputs: [output1, output2])

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testUngroupOutputs() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/ungroup_outputs")
            XCTAssertEqual(bodyString, "{\"output_ids\":[\"OutputID-1\",\"OutputID-2\"]}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let output1 = RoonOutput.make(outputID: "OutputID-1")
        let output2 = RoonOutput.make(outputID: "OutputID-2")

        // When
        let succeeded = await core.ungroupOutputs(outputs: [output1, output2])

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testChangeSettings() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            let jsonParts = [
                "\"shuffle\":true",
                "\"zone_or_output_id\":\"ZoneID-1\"",
                "\"auto_radio\":true",
                "\"loop\":\"next\""
            ]
            XCTAssertEqual(mooName, "com.roonlabs.transport:2/change_settings")
            jsonParts.forEach { part in
                XCTAssertEqual(bodyString?.contains(part), true)
            }
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let zone = RoonZone.make()

        // When
        let succeeded = await core.changeSettings(identifiable: zone, shuffle: true, autoRadio: true, loop: .next)

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(succeeded)
    }

    func testGetZones() async {
        // Given
        let zones = [RoonZone.make()]
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            XCTAssertEqual(mooName, "com.roonlabs.transport:2/get_zones")
            XCTAssertNil(body)
            XCTAssertNil(contentType)
            let response = GetZonesResponse(zones: zones)
            let body = response.jsonEncoded()
            completion?(.init(requestID: 1, verb: .request, name: .success, body: body))
        }

        // When
        let responseZones = await core.getZones()

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertEqual(responseZones, zones)
    }

    func testGetOutputs() async {
        // Given
        let outputs = [RoonOutput.make()]
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            XCTAssertEqual(mooName, "com.roonlabs.transport:2/get_outputs")
            XCTAssertNil(body)
            XCTAssertNil(contentType)
            let response = GetOutputsResponse(outputs: outputs)
            let body = response.jsonEncoded()
            completion?(.init(requestID: 1, verb: .request, name: .success, body: body))
        }

        // When
        let responseOutputs = await core.getOutputs()

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertEqual(responseOutputs, outputs)
    }

    func testSubscribeZonesSubscribed() async {
        // Given
        let zone1 = RoonZone.make()

        let zone1SeekChanged = ZoneSeekChanged(zoneId: zone1.id, queueTimeRemaining: 60, seekPosition: 30)
        var zone1NowPlaying = zone1.nowPlaying
        zone1NowPlaying?.seekPosition = 30
        let zone1AfterSeek = RoonZone.make(nowPlaying: zone1NowPlaying, queueTimeRemaining: 60)

        let zone2 = RoonZone.make(displayName: "Zone Name 2", zoneId: "ZoneID-2")
        let zone2Modified = RoonZone.make(displayName: "Different Zone Name 2", zoneId: "ZoneID-2")
        let zone3 = RoonZone.make(displayName: "Zone Name 3", zoneId: "ZoneID-3")
        let zones = [zone1, zone2]
        testSubscribeZonesSequence(steps: [
            (zones: zones, zonesAdded: [], zonesChanged: [], zonesRemoved: [], zonesSeekChanged: [], name: .subscribed, expectedZones: zones),
            (zones: [], zonesAdded: [zone3], zonesChanged: [], zonesRemoved: [], zonesSeekChanged: [], name: .changed, expectedZones: [zone1, zone2, zone3]),
            (zones: [], zonesAdded: [], zonesChanged: [zone2Modified], zonesRemoved: [], zonesSeekChanged: [], name: .changed, expectedZones: [zone1, zone2Modified, zone3]),
            (zones: [], zonesAdded: [], zonesChanged: [], zonesRemoved: ["ZoneID-2"], zonesSeekChanged: [], name: .changed, expectedZones: [zone1, zone3]),
            (zones: [], zonesAdded: [], zonesChanged: [], zonesRemoved: [], zonesSeekChanged: [zone1SeekChanged], name: .changed, expectedZones: [zone1AfterSeek, zone3]),
            (zones: [], zonesAdded: [], zonesChanged: [], zonesRemoved: [], zonesSeekChanged: [], name: .unsubscribed, expectedZones: []),
        ])
    }

    private func testSubscribeZonesSequence(steps: [
        (zones: [RoonZone], zonesAdded: [RoonZone], zonesChanged: [RoonZone], zonesRemoved: [String], zonesSeekChanged: [ZoneSeekChanged], name: MooName, expectedZones: [RoonZone])
    ]) {
        // Given
        var completion: ((MooMessage?) -> Void)?
        mooMock.subscribeHelperServiceNameRequestNameBodyCompletionClosure = { serviceName, requestName, body, receivedCompletion in
            XCTAssertEqual(serviceName, "com.roonlabs.transport:2")
            XCTAssertEqual(requestName, "zones")
            XCTAssertNil(body)
            completion = receivedCompletion
        }

        var expectedZones: [RoonZone] = []
        core.subscribeZones { subscriptionZones in
            XCTAssertEqual(expectedZones, subscriptionZones.sorted(by: { $0.zoneId < $1.zoneId }))
        }

        // When
        for step in steps {
            expectedZones = step.expectedZones
            let responseZones = SubscribeZonesResponse(zones: step.zones,
                                                       zonesAdded: step.zonesAdded,
                                                       zonesChanged: step.zonesChanged,
                                                       zonesRemoved: step.zonesRemoved,
                                                       zonesSeekChanged: step.zonesSeekChanged)
            let mooMessage = MooMessage(requestID: 1, verb: .continue, name: step.name, service: nil, headers: [:], body: responseZones.jsonEncoded())
            completion?(mooMessage)
        }

        // Then
        XCTAssertEqual(mooMock.subscribeHelperServiceNameRequestNameBodyCompletionCallsCount, 1)
    }

    func testSubscribeOutputs() {
        // Given
        var completion: ((MooMessage?) -> Void)?
        mooMock.subscribeHelperServiceNameRequestNameBodyCompletionClosure = { serviceName, requestName, body, receivedCompletion in
            XCTAssertEqual(serviceName, "com.roonlabs.transport:2")
            XCTAssertEqual(requestName, "outputs")
            XCTAssertNil(body)
            completion = receivedCompletion
        }
        let output1 = RoonOutput.make(outputID: "OutputID-1")
        let output2 = RoonOutput.make(outputID: "OutputID-2")

        let expectedOutputs: [RoonOutput] = [output1, output2]
        core.subscribeOutputs() { outputs in
            XCTAssertEqual(expectedOutputs, outputs)
        }

        // When
        let responseOutputs = SubscribeOutputsResponse(outputs: [output1, output2])
        let mooMessage = MooMessage(requestID: 1, verb: .continue, name: .changed, service: nil, headers: [:], body: responseOutputs.jsonEncoded())
        completion?(mooMessage)

        // Then
        XCTAssertEqual(mooMock.subscribeHelperServiceNameRequestNameBodyCompletionCallsCount, 1)
    }

    func testSubscribeQueue() {
        // Given
        var completion: ((MooMessage?) -> Void)?
        mooMock.subscribeHelperServiceNameRequestNameBodyCompletionClosure = { serviceName, requestName, body, receivedCompletion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(serviceName, "com.roonlabs.transport:2")
            XCTAssertEqual(requestName, "queue")
            XCTAssertEqual(bodyString?.contains("\"zone_or_output_id\":\"ZoneID-1\""), true)
            XCTAssertEqual(bodyString?.contains("\"max_item_count\":10"), true)
            completion = receivedCompletion
        }
        let zone = RoonZone.make()
        let item1 = QueueItem.make(id: 1)
        let item2 = QueueItem.make(id: 2)

        let expectedItems: [QueueItem] = [item1, item2]
        core.subscribeQueue(identifiable: zone, maxItems: 10) { items in
            XCTAssertEqual(expectedItems, items)
        }

        // When
        let responseOutputs = SubscribeQueueResponse(items: [item1, item2])
        let mooMessage = MooMessage(requestID: 1, verb: .continue, name: .changed, service: nil, headers: [:], body: responseOutputs.jsonEncoded())
        completion?(mooMessage)

        // Then
        XCTAssertEqual(mooMock.subscribeHelperServiceNameRequestNameBodyCompletionCallsCount, 1)
    }

    func testPlayFromHere() async {
        // Given
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/play_from_here")
            XCTAssertEqual(bodyString, "{\"zone_or_output_id\":\"ZoneID-1\",\"queue_item_id\":10}")
            XCTAssertNil(contentType)
            completion?(.init(requestID: 1, verb: .request, name: .success))
        }
        let zone = RoonZone.make()
        let queueItem = QueueItem.make()

        // When
        let response = await core.playFromHere(identifiable: zone, queueItem: queueItem)

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertTrue(response)
    }

    func testZoneByZoneID() async {
        // Given
        let zone1 = RoonZone.make(zoneId: "ZoneID-1")
        let zone2 = RoonZone.make(zoneId: "ZoneID-2")
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/get_zones")
            XCTAssertNil(bodyString)
            XCTAssertNil(contentType)

            let response = GetZonesResponse(zones: [zone1, zone2])
            let body = response.jsonEncoded()
            completion?(.init(requestID: 1, verb: .request, name: .success, body: body))
        }

        // When
        let response = await core.zone(byZoneID: "ZoneID-1")

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertEqual(response, zone1)
    }

    func testZoneByOutputID() async {
        // Given
        let output1 = RoonOutput.make(outputID: "OutputID-1")
        let zone1 = RoonZone.make(outputs: [output1], zoneId: "ZoneID-1")
        let output2 = RoonOutput.make(outputID: "OutputID-2")
        let zone2 = RoonZone.make(outputs: [output2], zoneId: "ZoneID-2")
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/get_zones")
            XCTAssertNil(bodyString)
            XCTAssertNil(contentType)

            let response = GetZonesResponse(zones: [zone1, zone2])
            let body = response.jsonEncoded()
            completion?(.init(requestID: 1, verb: .request, name: .success, body: body))
        }

        // When
        let response = await core.zone(byOutputID: "OutputID-2")

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertEqual(response, zone2)
    }

    func testZoneByObjectIDZone() async {
        // Given
        let zone1 = RoonZone.make(zoneId: "ZoneID-1")
        let zone2 = RoonZone.make(zoneId: "ZoneID-2")
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/get_zones")
            XCTAssertNil(bodyString)
            XCTAssertNil(contentType)

            let response = GetZonesResponse(zones: [zone1, zone2])
            let body = response.jsonEncoded()
            completion?(.init(requestID: 1, verb: .request, name: .success, body: body))
        }

        // When
        let response = await core.zone(byObjectID: "ZoneID-1")

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 1)
        XCTAssertEqual(response, zone1)
    }

    func testZoneByObjectIDOutput() async {
        // Given
        let output1 = RoonOutput.make(outputID: "OutputID-1")
        let zone1 = RoonZone.make(outputs: [output1], zoneId: "ZoneID-1")
        let output2 = RoonOutput.make(outputID: "OutputID-2")
        let zone2 = RoonZone.make(outputs: [output2], zoneId: "ZoneID-2")
        mooMock.sendRequestNameBodyContentTypeCompletionClosure = { mooName, body, contentType, completion in
            let bodyString = body.flatMap { String(data: $0, encoding: .utf8) }

            XCTAssertEqual(mooName, "com.roonlabs.transport:2/get_zones")
            XCTAssertNil(bodyString)
            XCTAssertNil(contentType)

            let response = GetZonesResponse(zones: [zone1, zone2])
            let body = response.jsonEncoded()
            completion?(.init(requestID: 1, verb: .request, name: .success, body: body))
        }

        // When
        let response = await core.zone(byObjectID: "OutputID-2")

        // Then
        XCTAssertEqual(mooMock.sendRequestNameBodyContentTypeCompletionCallsCount, 2)
        XCTAssertEqual(response, zone2)
    }

}

private extension RoonCore {

    static func make(
        coreID: String = "CoreID-1",
        displayName: String = "Core Name",
        displayVersion: String = "0.0.1",
        token: String? = "TestToken",
        providedServices: [RoonServiceName]? = [],
        httpPort: UInt16? = 8080,
        extensionHost: String? = "ExtensionHost",
        moo: Moo
    ) -> RoonCore {
        RoonCore(
            coreID: coreID,
            displayName: displayName,
            displayVersion: displayVersion,
            token: token,
            providedServices: providedServices,
            httpPort: httpPort,
            extensionHost: extensionHost,
            moo: moo
        )
    }

}

private extension RoonZone {

    static func make(
        displayName: String = "Zone Name",
        isNextAllowed: Bool = true,
        isPauseAllowed: Bool = true,
        isPlayAllowed: Bool = true,
        isPreviousAllowed: Bool = true,
        isSeekAllowed: Bool = true,
        nowPlaying: NowPlaying? = .init(artistImageKeys: [""],
                                        imageKey: "ImageKey",
                                        length: 300,
                                        oneLine: .init(line1: "Line 1", line2: nil, line3: nil),
                                        seekPosition: 0,
                                        threeLine: .init(line1: "Line 1", line2: "Line 2", line3: "Line 3"),
                                        twoLine: .init(line1: "Line 1", line2: "Line 2", line3: nil)),
        outputs: [RoonOutput] = [],
        queueItemsRemaining: Double = 1,
        queueTimeRemaining: Double = 1,
        settings: RoonZone.Settings = .init(autoRadio: true, loop: "", shuffle: false),
        state: RoonState = .playing,
        zoneId: String = "ZoneID-1"
    ) -> RoonZone {
        RoonZone(
            displayName: displayName,
            isNextAllowed: isNextAllowed,
            isPauseAllowed: isPauseAllowed,
            isPlayAllowed: isPlayAllowed,
            isPreviousAllowed: isPreviousAllowed,
            isSeekAllowed: isSeekAllowed,
            nowPlaying: nowPlaying,
            outputs: outputs,
            queueItemsRemaining: queueItemsRemaining,
            queueTimeRemaining: queueTimeRemaining,
            settings: settings,
            state: state,
            zoneId: zoneId
        )
    }

}

private extension RoonOutput {

    static func make(outputID: String = "OutputID-1") -> RoonOutput {
        RoonOutput(
            canGroupWithOutputIds: ["OutputID-2"],
            displayName: "Output Name",
            outputId: outputID,
            sourceControls: [],
            volume: nil,
            zoneId: "ZoneID-1"
        )
    }

}

private extension QueueItem {

    static func make(
        id: Int = 10,
        imageKey: String? = "ImageKey1",
        length: Int = 300,
        oneLine: DisplayLines = .init(line1: "Line 1", line2: nil, line3: nil),
        threeLines: DisplayLines = .init(line1: "Line 1", line2: "Line 2", line3: "Line 3"),
        twoLines: DisplayLines = .init(line1: "Line 1", line2: "Line 2", line3: nil)
    ) -> QueueItem {
        QueueItem(
            id: id,
            imageKey: imageKey,
            length: length,
            oneLine: oneLine,
            threeLines: threeLines,
            twoLines: twoLines
        )
    }

}
