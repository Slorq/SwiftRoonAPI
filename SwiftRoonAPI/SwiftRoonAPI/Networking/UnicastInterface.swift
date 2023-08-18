//
//  UnicastInterface.swift
//  
//
//  Created by Alejandro Maya on 25/06/23.
//

import Foundation

class UnicastInterface {
    
    var sendSocket: SocketFacade?

    init(sendSocket: SocketFacade? = nil) {
        self.sendSocket = sendSocket
    }
}
