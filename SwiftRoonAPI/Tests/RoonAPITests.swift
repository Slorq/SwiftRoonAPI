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
