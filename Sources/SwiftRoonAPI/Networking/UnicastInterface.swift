//
//  UnicastInterface.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

class UnicastInterface {
    var sendSocket: Socket?
    let interfaceSequence: Int

    init(sendSocket: Socket? = nil, interfaceSequence: Int) {
        self.sendSocket = sendSocket
        self.interfaceSequence = interfaceSequence
    }
}
