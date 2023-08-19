//
//  RoonAPITests.swift
//  
//
//  Created by Alejandro Maya on 18/08/23.
//

@testable import SwiftRoonAPI
import XCTest

final class SwiftRoonAPITests: XCTestCase {

    private var sood: _SoodMock!
    private var roonAPI: RoonAPI!
    private let options: RoonOptions = .init(displayName: "DisplayName",
                                             displayVersion: "DisplayVersion",
                                             email: "email@test.com",
                                             extensionID: "ExtensionID",
                                             publisher: "PublisherName",
                                             website: "www.website.com")

    override func setUp() {
        sood = _SoodMock()
        sood.underlyingIsStarted = false
        roonAPI = RoonAPI(options: options, sood: sood)
        super.setUp()
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

    func testInitRequiredServicesWithoutCorePairedOrFoundThrowsError() {
        // Given
        roonAPI.corePaired = nil
        roonAPI.coreFound = nil

        // When
        XCTAssertThrowsError(
            try roonAPI.initServices(requiredServices: [ServiceRegistry(services: [RegisteredService(name: "ServiceName", subservices: [:])])])
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
            try roonAPI.initServices(optionalServices: [ServiceRegistry(services: [RegisteredService(name: "ServiceName", subservices: [:])])])
        ) { error in
            // Then
            XCTAssertEqual(error as? RoonAPIError, RoonAPIError.unableToInitServices(details: "Roon Extensions options has required or optional services, but has neither corePaired nor coreFound."))
        }
    }

    func testPairingServiceIsInitializedOnInitServicesWhenCorePairedExists() throws {
        // Given
        roonAPI.corePaired = { core in }

        // When
        try roonAPI.initServices()

        // Then
        XCTAssertNotNil(roonAPI.testHooks.pairingService)
    }

}
