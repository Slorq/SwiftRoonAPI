//
//  _Moo.swift
//  
//
//  Created by Alejandro Maya on 22/07/23.
//

import Foundation

public protocol _Moo: AnyObject, AutoMockable {

    var mooID: Int { get }
    var core: RoonCore? { get set }

    func sendRequest(name: MooName, body: Data?, contentType: String?, completion: ((MooMessage?) -> Void)?)
    func subscribeHelper(serviceName: String, requestName: String, body: Data?, completion: ((MooMessage?) -> Void)?)
    func sendContinue(_ name: MooName, body: Data?, message: MooMessage, completion: ((MooMessage?) -> Void)?)
    func sendComplete(_ name: MooName, body: Data?, message: MooMessage, completion: ((MooMessage?) -> Void)?)

}

public extension _Moo {

    func sendRequest(name: MooName, body: Data? = nil, contentType: String?) {
        sendRequest(name: name, body: body, contentType: contentType, completion: nil)
    }

    func subscribeHelper(serviceName: String, requestName: String, body: Data? = nil) {
        subscribeHelper(serviceName: serviceName, requestName: requestName, body: body, completion: nil)
    }

    func sendContinue(_ name: MooName, body: Data? = nil, message: MooMessage) {
        sendContinue(name, body: body, message: message, completion: nil)
    }

    func sendComplete(_ name: MooName = .success, body: Data? = nil, message: MooMessage) {
        sendComplete(name, body: body, message: message, completion: nil)
    }
}
