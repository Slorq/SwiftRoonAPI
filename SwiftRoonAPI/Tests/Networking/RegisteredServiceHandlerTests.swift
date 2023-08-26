//
//  RegisteredServiceHandlerTests.swift
//  
//
//  Created by Alejandro Maya on 3/07/23.
//

@testable import SwiftRoonAPI
import XCTest

final class RegisteredServiceHandlerTests: XCTestCase {

    func testSendContinueAll() {
        // Given
        let subservice = "subscribe_pairing"
        let service: RegisteredService = RegisteredService(name: subservice)
        let transport = _MooTransportMock()
        let moo = Moo(transport: transport)
        let name = "name"
        let body = "data".data(using: .utf8)

        service.register(handler: .init(message: .init(requestID: 1, verb: .request, name: .continueChanged)),
                         subscriptionName: subservice,
                         mooID: 1,
                         subscriptionKey: "string2")

        // When
        RegisteredServiceHandler.sendContinueAll(
            service: service,
            moo: moo,
            subservice: subservice,
            name: name,
            body: body
        )

        // Then
        XCTAssertTrue(transport.sendDataCalled)
        XCTAssertEqual(transport.sendDataReceivedInvocations.count, 1)
        XCTAssertEqual(transport.sendDataReceivedData.map { String(data: $0, encoding: .utf8) }, "MOO/1 CONTINUE name\nRequest-Id: 1\n\n")
    }

}
