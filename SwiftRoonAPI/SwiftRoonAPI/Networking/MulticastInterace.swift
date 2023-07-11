//
//  MulticastInterace.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

class MulticastInterface {
    var sendSocket: SocketFacade?
    var receiveSocket: SocketFacade?
    var interfaceSequence: Int
    var broadcast: String?

    init(sendSocket: SocketFacade? = nil, receiveSocket: SocketFacade? = nil, interfaceSequence: Int, broadcast: String? = nil) {
        self.sendSocket = sendSocket
        self.receiveSocket = receiveSocket
        self.interfaceSequence = interfaceSequence
        self.broadcast = broadcast
    }
}
