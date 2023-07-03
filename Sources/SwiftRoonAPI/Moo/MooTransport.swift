//
//  MooTransport.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 5/12/22.
//

import Combine
import Foundation
import SwiftLogger

enum MooTransportError: Error {
    case invalidURL
    case unknownSocketResponse
}

protocol MooTransportDelegate: AnyObject, AutoMockable {
    func transportDidOpen(_ transport: MooTransport)
    func transportDidClose(_ transport: MooTransport)
    func transport(_ transport: MooTransport, didReceiveError error: Error)
    func transport(_ transport: MooTransport, didReceiveData data: Data)
    func transport(_ transport: MooTransport, didReceiveString string: String)
}

protocol _URLSessionWebSocketTask: AutoMockable {
    var delegate: URLSessionTaskDelegate? { get set }

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    func resume()
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping ((Error)?) -> Void)
    func sendPing(pongReceiveHandler: @escaping @Sendable (Error?) -> Void)
}

extension URLSessionWebSocketTask: _URLSessionWebSocketTask {}

class MooTransport: NSObject {

    private let host: String
    private let port: UInt16
    private let logger = Logger()
    private var webSocket: _URLSessionWebSocketTask
    private(set) var isAlive = false
    private let timerPublisher: TimerProtocol
    private var timerSubscription: Cancellable?
    weak var delegate: MooTransportDelegate?

    private static var defaultTimePublisher: TimerProtocol {
        Timer.publish(every: 10, on: .current, in: .common)
    }

    init(host: String, port: UInt16, webSocket: _URLSessionWebSocketTask? = nil, timerPublisher: TimerProtocol = MooTransport.defaultTimePublisher) throws {
        guard let url = URL(string: "ws://\(host):\(port)/api") else {
            throw MooTransportError.invalidURL
        }

        self.host = host
        self.port = port
        self.webSocket = webSocket ?? URLSession.shared.webSocketTask(with: url)
        self.timerPublisher = timerPublisher

        super.init()

        self.webSocket.delegate = self
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
            }

            self.scheduleReceive()
        }
    }

    func close(closeCode: URLSessionWebSocketTask.CloseCode = .goingAway) {
        self.logger.log("Transport - close")
        self.isAlive = false
        self.timerSubscription?.cancel()
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

extension MooTransport: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        logger.log("MooTransport - didOpen")
        isAlive = true

        self.timerSubscription = timerPublisher.getTimerPublisher()
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }

                guard self.isAlive else {
                    self.logger.log("Roon API Connection to \(self.host):\(self.port) closed due to missed heartbeat")
                    self.timerSubscription?.cancel()
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
        logger.log("MooTransport - didClose")
        isAlive = false
        delegate?.transportDidClose(self)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        logger.log("MooTransport - didCompleteWithError")
        isAlive = false
        error.map { delegate?.transport(self, didReceiveError: $0) }
    }
}

protocol TimerProtocol {
    func getTimerPublisher() -> AnyPublisher<Date, Never>
}

extension Timer.TimerPublisher: TimerProtocol {

    func getTimerPublisher() -> AnyPublisher<Date, Never> {
        self.autoconnect().eraseToAnyPublisher()
    }
}
