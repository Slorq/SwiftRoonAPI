//
//  SocketFactory.swift
//  
//
//  Created by Alejandro Maya on 18/08/23.
//

import CocoaAsyncSocket
import Foundation

protocol _SocketFactory {

    func make() -> _AsyncSocket
}

struct SocketFactory: _SocketFactory {

    func make() -> _AsyncSocket {
        GCDAsyncUdpSocket()
    }
}
