//
//  RoonAPITests.swift
//  
//
//  Created by Alejandro Maya on 18/08/23.
//

@testable import SwiftRoonAPI
import XCTest

struct MooTransportMockFactory: _MooTransportFactory {

    func make(host: String, port: UInt16) throws -> _MooTransport {
        _MooTransportMock()
    }
}

final class SwiftRoonAPITests: XCTestCase {

    private var sood: _SoodMock!
    private var roonAPI: RoonAPI!
    private let details: RoonExtensionDetails = .init(displayName: "DisplayName",
                                                      displayVersion: "DisplayVersion",
                                                      email: "email@test.com",
                                                      extensionID: "ExtensionID",
                                                      publisher: "PublisherName",
                                                      website: "www.website.com")

    override func setUp() {
        sood = _SoodMock()
        sood.underlyingIsStarted = false
        roonAPI = RoonAPI(details: details, sood: sood, mooTransportFactory: MooTransportMockFactory())
        super.setUp()
    }

    func testInitWithDefaultProperties() {
        // Given
        // When
        let roonAPI = RoonAPI(details: details)

        // Then
        XCTAssertTrue(roonAPI.testHooks.sood is Sood)
        XCTAssertTrue(roonAPI.testHooks.mooTransportFactory is MooTransportFactory)
    }

    func testSoodQueryWhenStartDiscoveryIsCalled() {
        // Given
        sood.startClosure = { closure in closure?() }

        // When
        roonAPI.startDiscovery()

        // Then
        XCTAssertTrue(sood.queryServiceIdCalled)
    }

    func testSoodStartsOnlyOnceOnStartDiscovery() {
        // Given
        sood.startClosure = { [weak self] closure in
            self?.sood.underlyingIsStarted = true
            closure?()
        }

        // When
        roonAPI.startDiscovery()
        roonAPI.startDiscovery()

        // Then
        XCTAssertEqual(sood.queryServiceIdCallsCount, 1)
    }

    func testSoodQueryIsCalledWhenOnSoodNetworkIsCalled() {
        // Given // When
        sood.onNetwork?()

        // Then
        XCTAssertEqual(sood.queryServiceIdReceivedServiceId, "00720724-5143-4a9b-abac-0e50cba674bb")
    }

    func testSoodConnectionIsCreatedOnSoodMessage() {
        // Given // When
        sood.onMessage?(SoodMessage(props: SoodMessage.Props(serviceId: "00720724-5143-4a9b-abac-0e50cba674bb",
                                                             uniqueId: "fc519bd4-30c9-4e38-b8ea-53f5816ba75e",
                                                             httpPort: "9300",
                                                             tid: "a24649ef-e7cd-430a-a2bc-db4ed6a3f8c8",
                                                             tcpPort: "9150",
                                                             httpsPort: "55000",
                                                             displayVersion: "1.0 (build 1303) production",
                                                             name: "MacBook-Pro"),
                                    from: SoodMessage.From(ip: "172.20.10.7",
                                                           port: 50942),
                                    type: "R"))

        // Then
        XCTAssertFalse(roonAPI.testHooks.soodConnections.isEmpty)
    }

    func testSoodConnectionIsNotCreatedIfServiceIDIsMissing() {
        // Given // When
        sood.onMessage?(SoodMessage(props: SoodMessage.Props(serviceId: nil,
                                                            uniqueId: "fc519bd4-30c9-4e38-b8ea-53f5816ba75e"),
                                    from: SoodMessage.From(ip: "172.20.10.7",
                                                           port: 50942),
                                    type: "R"))

        // Then
        XCTAssertTrue(roonAPI.testHooks.soodConnections.isEmpty)
    }

    func testSoodConnectionIsNotCreatedIfUniqueIDIsMissing() {
        // Given // When
        sood.onMessage?(SoodMessage(props: SoodMessage.Props(serviceId: "00720724-5143-4a9b-abac-0e50cba674bb",
                                                             uniqueId: nil),
                                    from: SoodMessage.From(ip: "172.20.10.7",
                                                           port: 50942),
                                    type: "R"))

        // Then
        XCTAssertTrue(roonAPI.testHooks.soodConnections.isEmpty)
    }

    func testSoodConnectionIsNotCreatedIfAlreadyExists() {
        // Given
        let soodMessage = SoodMessage(props: SoodMessage.Props(serviceId: "00720724-5143-4a9b-abac-0e50cba674bb",
                                                               uniqueId: "fc519bd4-30c9-4e38-b8ea-53f5816ba75e",
                                                               httpPort: "9300",
                                                               tid: "a24649ef-e7cd-430a-a2bc-db4ed6a3f8c8",
                                                               tcpPort: "9150",
                                                               httpsPort: "55000",
                                                               displayVersion: "1.0 (build 1303) production",
                                                               name: "MacBook-Pro"),
                                      from: SoodMessage.From(ip: "172.20.10.7",
                                                             port: 50942),
                                      type: "R")
        sood.onMessage?(soodMessage)
        XCTAssertEqual(roonAPI.testHooks.soodConnections.count, 1)
        let soodConnection = roonAPI.testHooks.soodConnections.first?.value

        // When
        sood.onMessage?(soodMessage)

        // Then
        XCTAssertEqual(roonAPI.testHooks.soodConnections.count, 1)
        XCTAssertTrue(soodConnection === roonAPI.testHooks.soodConnections.first?.value)
    }

    func testRegisterExtensionWithServices() throws {
        // Given
        roonAPI.corePaired = { _ in }
        try roonAPI.registerServices(optionalServices: [RoonService(name: "OptionalService1")],
                                     requiredServices: [RoonService(name: "RequiredService1")],
                                     providedServices: [RoonService(name: "ProvidedService1")])
        createSoodConnection()
        let moo = try XCTUnwrap(roonAPI.testHooks.soodConnections.first?.value)
        let transport = try XCTUnwrap(moo.testHooks.transport as? _MooTransportMock)
        XCTAssertNotNil(roonAPI.testHooks.serviceRequestHandlers["com.roonlabs.ping:1"])
        XCTAssertNotNil(roonAPI.testHooks.serviceRequestHandlers["com.roonlabs.pairing:1"])

        // When
        moo.onOpen?(moo)

        // Then
        XCTAssertEqual(transport.sendDataCallsCount, 1)
        XCTAssertEqual(transport.sendDataReceivedData,
                       "MOO/1 REQUEST com.roonlabs.registry:1/info\nRequest-Id: 0\n\n".data(using: .utf8))
        let infoResponse = try XCTUnwrap("MOO/1 COMPLETE Success\nContent-Type: application/json\nRequest-Id: 0\nContent-Length: 138\n\n{\"core_id\":\"fc519bd4-30c9-4e38-b8ea-53f5816ba75e\",\"display_name\":\"Alejandros-MacBook-Pro\",\"display_version\":\"2.0 (build 1303) production\"}".data(using: .utf8))
        moo.transport(transport, didReceiveData: infoResponse)
        XCTAssertEqual(transport.sendDataCallsCount, 2)
        let sentData = try XCTUnwrap(transport.sendDataReceivedData)
        let sentString = try XCTUnwrap(String(data: sentData, encoding: .utf8))
        XCTAssertTrue(sentString.contains("MOO/1 REQUEST com.roonlabs.registry:1/register\n"))
        XCTAssertTrue(sentString.contains("Request-Id: 1"))
        XCTAssertTrue(sentString.contains("Content-Length: 320"))
        XCTAssertTrue(sentString.contains("Content-Type: application/json"))
        XCTAssertTrue(sentString.contains("\"provided_services\":[\"ProvidedService1\",\"com.roonlabs.ping:1\"]"))
        XCTAssertTrue(sentString.contains("\"required_services\":[\"RequiredService1\"]"))
        XCTAssertTrue(sentString.contains("\"website\":\"www.website.com\""))
        XCTAssertTrue(sentString.contains("\"optional_services\":[\"OptionalService1\"]"))
        XCTAssertTrue(sentString.contains("\"email\":\"email@test.com\""))
        XCTAssertTrue(sentString.contains("\"publisher\":\"PublisherName\""))
        XCTAssertTrue(sentString.contains("\"display_name\":\"DisplayName\""))
        XCTAssertTrue(sentString.contains("\"extension_id\":\"ExtensionID\""))
        XCTAssertTrue(sentString.contains("\"display_version\":\"DisplayVersion\""))
    }

    func testInitRequiredServicesWithoutCorePairedOrFoundThrowsError() {
        // Given
        roonAPI.corePaired = nil
        roonAPI.coreFound = nil

        // When
        XCTAssertThrowsError(
            try roonAPI.registerServices(requiredServices: [RoonService(name: "ServiceName")])
        ) { error in
            // Then
            XCTAssertEqual(error as? RoonAPIError, RoonAPIError.unableToInitServices(details: "Roon Extensions options has required or optional services, but has neither corePaired nor coreFound."))
        }
    }

    func testInitOptionalServicesWithoutCorePairedOrFoundThrowsError() {
        // Given
        roonAPI.corePaired = nil
        roonAPI.coreFound = nil

        // When
        XCTAssertThrowsError(
            try roonAPI.registerServices(requiredServices: [RoonService(name: "ServiceName")])
        ) { error in
            // Then
            XCTAssertEqual(error as? RoonAPIError, RoonAPIError.unableToInitServices(details: "Roon Extensions options has required or optional services, but has neither corePaired nor coreFound."))
        }
    }

    func testPairingServiceIsInitializedOnInitServicesWhenCorePairedExists() throws {
        // Given
        roonAPI.corePaired = { core in }

        // When
        try roonAPI.registerServices()

        // Then
        XCTAssertNotNil(roonAPI.testHooks.pairingService)
    }

    func testPingSucceeds() throws {
        // Given
        try roonAPI.registerServices()
        createSoodConnection()
        let moo = try XCTUnwrap(roonAPI.testHooks.soodConnections.first?.value)
        let mooTransport = try XCTUnwrap(moo.testHooks.transport as? _MooTransportMock)
        let pingMessage = "MOO/1 REQUEST com.roonlabs.ping:1/ping\nLogging: quiet\nRequest-Id: 1\n\n"
        let data = try XCTUnwrap(pingMessage.data(using: .utf8))

        // When
        moo.transport(mooTransport, didReceiveData: data)

        // Then
        let sentData = try XCTUnwrap(mooTransport.sendDataReceivedData)
        let sentMessage = try XCTUnwrap(String(data: sentData, encoding: .utf8))
        XCTAssertEqual(sentMessage, "MOO/1 COMPLETE Success\nRequest-Id: 1\n\n")
    }

    func testUnrecognizedSubserviceSendsComplete() throws {
        // Given
        try roonAPI.registerServices(providedServices: [
            RoonService(name: "ProvidedService1")
        ])
        createSoodConnection()
        let moo = try XCTUnwrap(roonAPI.testHooks.soodConnections.first?.value)
        let unrecognizedSubservice = "pong"
        let message = "MOO/1 REQUEST com.roonlabs.ping:1/\(unrecognizedSubservice)\nRequest-Id: 1\n\n"
        let data = try XCTUnwrap(message.data(using: .utf8))

        // When
        moo.transport(moo.testHooks.transport, didReceiveData: data)

        // Then
        let sentData = try XCTUnwrap((moo.testHooks.transport as? _MooTransportMock)?.sendDataReceivedData)
        let sentMessage = try XCTUnwrap(String(data: sentData, encoding: .utf8))
        XCTAssertEqual(sentMessage, "MOO/1 COMPLETE InvalidRequest\nRequest-Id: 1\n\n")
    }

    func testOnSoodConnectionClose() throws {
        // Given
        try roonAPI.registerServices()
        createSoodConnection()
        let moo = try XCTUnwrap(roonAPI.testHooks.soodConnections.first?.value)
        XCTAssertFalse(roonAPI.testHooks.soodConnections.isEmpty)

        // When
        moo.transportDidClose(moo.testHooks.transport)

        // Then
        XCTAssertTrue(roonAPI.testHooks.soodConnections.isEmpty)
    }

}

extension SwiftRoonAPITests {

    private func createSoodConnection() {
        sood.onMessage?(SoodMessage(props: SoodMessage.Props(serviceId: "00720724-5143-4a9b-abac-0e50cba674bb",
                                                             uniqueId: "fc519bd4-30c9-4e38-b8ea-53f5816ba75e",
                                                             httpPort: "9300",
                                                             tid: "a24649ef-e7cd-430a-a2bc-db4ed6a3f8c8",
                                                             tcpPort: "9150",
                                                             httpsPort: "55000",
                                                             displayVersion: "1.0 (build 1303) production",
                                                             name: "MacBook-Pro"),
                                    from: SoodMessage.From(ip: "172.20.10.7",
                                                           port: 50942),
                                    type: "R"))
    }
}
