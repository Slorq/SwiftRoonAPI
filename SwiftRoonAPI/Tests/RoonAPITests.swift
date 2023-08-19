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

    func testOnMessageWhenOnSoodMessage() {
        // Given
        let soodMessage = SoodMessage(props: .init(), from: .init(port: 9300), type: "Q")

        let expectation = expectation(description: "onMessage should be called")
        sood.onMessage = { receivedMessage in
            XCTAssertEqual(receivedMessage, soodMessage)
            expectation.fulfill()
        }

        // When
        sood.onMessage?(soodMessage)

        // Then
        waitForExpectations(timeout: 0.1)
    }

    func testSoodQueryWhenStartDiscoveryIsCalled() {
        // Given
        sood.startClosure = { closure in closure?() }

        // When
        roonAPI.startDiscovery()

        // Then
        XCTAssertTrue(sood.queryServiceIdCalled)
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

}
