//
//  UnicastInterface.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

class UnicastInterface {
    var sendSocket: SocketFacade?
    let interfaceSequence: Int

    init(sendSocket: SocketFacade? = nil, interfaceSequence: Int) {
        self.sendSocket = sendSocket
        self.interfaceSequence = interfaceSequence
    }
}
