//
//  Transport.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 5/12/22.
//

import Combine
import Foundation

enum TransportError: Error {
    case invalidURL
    case unknownSocketResponse
}

protocol TransportDelegate: AnyObject {
    func transportDidOpen(_ transport: Transport)
    func transportDidClose(_ transport: Transport)
    func transport(_ transport: Transport, didReceiveError error: Error)
    func transport(_ transport: Transport, didReceiveData data: Data)
    func transport(_ transport: Transport, didReceiveString string: String)
}

class Transport: NSObject {

    private let host: String
    private let port: UInt16
    private let logger = Logger()
    private let webSocket: URLSessionWebSocketTask
    private var isAlive = false
    private var timer: Cancellable?
    weak var delegate: TransportDelegate?

    init(host: String, port: UInt16) throws {
        guard let url = URL(string: "ws://\(host):\(port)/api") else {
            throw TransportError.invalidURL
        }

        self.host = host
        self.port = port
        self.webSocket = URLSession.shared.webSocketTask(with: url)

        super.init()

        webSocket.delegate = self
    }

    func resume() {
        webSocket.resume()
    }

    func send(data: Data) {
        logger.log("Transport - sendData - \(String(data: data, encoding: .utf8) ?? "")")
        webSocket.send(.data(data)) { [weak self] error in
            guard let self else { return }
            if let error {
                self.delegate?.transport(self, didReceiveError: error)
            } else {
                self.receive()
            }
        }
    }

    func close(closeCode: URLSessionWebSocketTask.CloseCode = .goingAway) {
        self.logger.log("Transport - close")
        self.isAlive = false
        self.timer = nil
        self.webSocket.cancel(with: closeCode, reason: nil)
        self.delegate?.transportDidClose(self)
    }

    private func receive() {
        webSocket.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self.logger.log("Transport - Web socket did receive data \(String(data: data, encoding: .utf8) ?? "")")
                    self.delegate?.transport(self, didReceiveData: data)
                case .string(let string):
                    self.logger.log("Transport - Web socket did receive string \(string)")
                    self.delegate?.transport(self, didReceiveString: string)
                @unknown default:
                    self.delegate?.transport(self, didReceiveError: TransportError.unknownSocketResponse)
                }
                self.scheduleReceive()
            case .failure(let error):
                self.handleReceiveError(error)
            }
        }
    }

    private func handleReceiveError(_ error: Error) {
        let error = error as NSError
        if error.code == 57 || error.code == 60 || error.code == 54 {
            close()
        } else {
            delegate?.transport(self, didReceiveError: error)
            scheduleReceive()
        }
    }

    private func scheduleReceive() {
        if isAlive {
            receive()
        }
    }
}

extension Transport: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        logger.log("Transport - didOpen")
        isAlive = true

        self.timer = Timer.publish(every: 10, on: .current, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }

                guard self.isAlive else {
                    self.logger.log("Roon API Connection to \(self.host):\(self.port) closed due to missed heartbeat")
                    self.timer?.cancel()
                    return
                }

                self.isAlive = false
                self.webSocket.sendPing { error in
                    if error == nil {
                        self.isAlive = true
                    }
                }
            })

        delegate?.transportDidOpen(self)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        logger.log("Transport - didClose")
        isAlive = false
        delegate?.transportDidClose(self)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        logger.log("Transport - didCompleteWithError")
        isAlive = false
    }
}
