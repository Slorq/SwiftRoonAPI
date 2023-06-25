//
//  MulticastInterace.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

class MulticastInterface {
    var sendSocket: Socket?
    var receiveSocket: Socket?
    var interfaceSequence: Int
    var broadcast: String?

    init(sendSocket: Socket? = nil, receiveSocket: Socket? = nil, interfaceSequence: Int, broadcast: String? = nil) {
        self.sendSocket = sendSocket
        self.receiveSocket = receiveSocket
        self.interfaceSequence = interfaceSequence
        self.broadcast = broadcast
    }
}
