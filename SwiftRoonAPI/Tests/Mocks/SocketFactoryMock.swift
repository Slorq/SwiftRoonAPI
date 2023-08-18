//
//  SocketFactoryMock.swift
//  
//
//  Created by Alejandro Maya on 18/08/23.
//

@testable import SwiftRoonAPI

struct SocketFactoryMock: _SocketFactory {

    func make() -> _AsyncSocket {
        _AsyncSocketMock()
    }
}
