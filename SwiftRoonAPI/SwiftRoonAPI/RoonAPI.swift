//
//  RoonAPI.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 5/12/22.
//

import class Combine.AnyCancellable
import Foundation
import SwiftLogger
import SwiftRoonAPICore
import SystemConfiguration

private let roonServiceID = "00720724-5143-4a9b-abac-0e50cba674bb"

struct RoonServices {
    let required: [RoonServiceName]
    let optional: [RoonServiceName]
    let provided: [RoonServiceName]
}

public class RoonAPI: NSObject {

    public typealias RoonCoreCompletionHandler = (RoonCore) -> Void
    public typealias RoonErrorCompletionHandler = (Error) -> Void

    private let logger = Logger()
    private var extensionRegInfo: RoonExtensionRegInfo
    private var isPaired = false
    private var moo: Moo!
    private var options: RoonOptions
    private var pairedCore: RoonCore?
    private var pairingService: PairingServiceRegistry?
    private var periodicScanSubscription: AnyCancellable?
    private var roonSettings = RoonSettings()
    private var scanCount = 0
    private var serviceRequestHandlers: [String: (Moo, MooMessage?) -> Void] = [:]
    private var servicesOpts: ([ServiceRegistry], [ServiceRegistry], [ServiceRegistry])?
    private var sood: Sood?
    private var soodConnections: [String: Moo] = [:]
    public var coreFound: RoonCoreCompletionHandler?
    public var coreLost: RoonCoreCompletionHandler?
    public var corePaired: RoonCoreCompletionHandler?
    public var coreUnpaired: RoonCoreCompletionHandler?
    public var onError: RoonErrorCompletionHandler?

    public init(options: RoonOptions) {
        self.options = options
        self.extensionRegInfo = .init(options: options)

        super.init()
    }

    public func startDiscovery() {
        guard sood == nil else {
            logger.log(level: .warning, "Discovery has already been started")
            return
        }

        logger.log(level: .info, "Starting discovery")
        let sood = Sood()
        self.sood = sood
        sood.onMessage = { [weak self] in self?.onSoodMessage($0) }
        sood.onNetwork = { [weak self] in self?.onSoodNetwork() }
        sood.start { [weak self] in self?.onSoodStart() }
    }

    public func initServices(optionalServices: [ServiceRegistry] = [],
                             requiredServices: [ServiceRegistry] = [],
                             providedServices: [ServiceRegistry] = []) throws {
        logger.log(level: .info,
                   logMessage(optionalServices: optionalServices,
                              requiredServices: requiredServices,
                              providedServices: providedServices)
        )

        let optionalServices = optionalServices
        let requiredServices = requiredServices
        var providedServices = providedServices

        if !requiredServices.isEmpty || !optionalServices.isEmpty {
            if corePaired == nil && coreFound == nil {
                throw RoonAPIError.unableToInitServices(details: "Roon Extensions options has required or optional services, but has neither corePaired nor coreFound.")
            }
        }

        if corePaired != nil {
            let onPairingStart: (Moo, MooMessage) -> Void = { [weak self] moo, request in
                let pairedCore = (self?.pairedCore?.coreID).map { PairedCore(coreID: $0) }
                let body = try? pairedCore?.jsonEncoded()
                moo.sendContinue(MooName.subscribed, body: body, message: request)
            }
            let getPairing: (Moo, MooMessage) -> Void = { [weak self] moo, request in
                let pairedCore = (self?.pairedCore?.coreID).map { PairedCore(coreID: $0) }
                let body = try? pairedCore?.jsonEncoded()
                moo.sendComplete(MooName.success, body: body, message: request)
            }
            let pair: (Moo, MooMessage) -> Void = { [weak self] moo, request in
                guard let self,
                      let body = request.body,
                      let core = try? JSONDecoder.default.decode(RoonCore.self, from: body) else {
                    return
                }

                if self.pairedCore?.coreID != core.coreID {
                    if let pairedCore = self.pairedCore {
                        self.coreLost?(pairedCore)
                        self.pairedCore = nil
                    }
                    self.pairingService?.foundCore(core)
                }
            }
            let service = registerService(serviceName: .pairing,
                                          specs: .init(
                                            subscriptions: [
                                                .init(subscribeName: "subscribe_pairing",
                                                      unsubscribeName: "unsubscribe_pairing",
                                                      start: onPairingStart)
                                            ],
                                            methods: [
                                                "get_pairing": getPairing,
                                                "pair": pair
                                            ]
                                          )
            )

            pairingService = .init(services: [service],
                                   foundCore: { [weak self] core in
                guard let self else { return }
                if self.pairedCore == nil {
                    roonSettings.pairedCoreID = core.coreID

                    self.pairedCore = core
                    self.isPaired = true

                    let pairedCore = PairedCore(coreID: core.coreID)
                    let body = try? pairedCore.jsonEncoded()
                    body.map {
                        RegisteredServiceHandler.sendContinueAll(subservices: service.subservices,
                                                                 moo: core.moo,
                                                                 subservice: "subscribe_pairing",
                                                                 name: "Changed",
                                                                 body: $0)
                    }
                }
                if core.coreID == self.pairedCore?.coreID {
                    self.corePaired?(core)
                }
            },
                                   lostCore: { [weak self] core in
                guard let self else { return }
                if core.coreID == self.pairedCore?.coreID {
                    self.isPaired = false
                }
                self.coreUnpaired?(core)
            })
        }

        providedServices.append(.init(services: [
            registerService(serviceName: "com.roonlabs.ping:1", specs: .init(methods: [
                "ping": { moo, request in
                    moo.sendComplete(message: request)
                }
            ]))
        ]))

        self.extensionRegInfo.optionalServices.append(contentsOf: optionalServices.reduce(into: [], {
            $0.append(contentsOf: $1.services.compactMap { $0.name })
        }))
        self.extensionRegInfo.requiredServices.append(contentsOf: requiredServices.reduce(into: [], {
            $0.append(contentsOf: $1.services.compactMap { $0.name })
        }))
        self.extensionRegInfo.providedServices.append(contentsOf: providedServices.reduce(into: [], {
            $0.append(contentsOf: $1.services.compactMap { $0.name })
        }))

        self.servicesOpts = (optionalServices, requiredServices, providedServices)
    }

    public func registerService(serviceName: String, specs: RoonServiceSpecs) -> RegisteredService {
        logger.log(level: .info, "Registering service \(serviceName)")
        let registeredService = RegisteredService()

        specs.subscriptions.forEach { s in
            let subname = s.subscribeName
            registeredService.subservices[subname] = [:]
            specs.methods[subname] = { moo, request in
                guard let body = request.body,
                      let subscriptionBody = try? JSONDecoder.default.decode(SubscriptionBody.self, from: body) else {
                    assertionFailure("Unable to decode subscriptionBody")
                    return
                }

                let subscriptionMessageHandler = SubscriptionMessageHandler(message: request)
                let originalSendComplete = subscriptionMessageHandler.sendComplete
                subscriptionMessageHandler.sendComplete = { moo, name, body, message in
                    originalSendComplete(moo, name, body, message)
                    registeredService.subservices[subname]?[moo.mooID]?[subscriptionBody.subscriptionKey] = nil
                }
                s.start(moo, request)
                if registeredService.subservices[subname]?[moo.mooID] == nil {
                    registeredService.subservices[subname]?[moo.mooID] = [:]
                }
                registeredService.subservices[subname]?[moo.mooID]?[subscriptionBody.subscriptionKey] = subscriptionMessageHandler
            }

            specs.methods[s.unsubscribeName] = { moo, request in
                guard let body = request.body,
                      let subscriptionBody = try? JSONDecoder.default.decode(SubscriptionBody.self, from: body) else {
                    assertionFailure("Unable to decode subscriptionBody")
                    return
                }

                registeredService.subservices[subname]?[moo.mooID]?[subscriptionBody.subscriptionKey] = nil
                s.end?()
                moo.sendComplete(.unsubscribed, message: request)
            }
        }

        serviceRequestHandlers[serviceName] = { moo, request in
            if let request {
                if let method = specs.methods[request.name] {
                    method(moo, request)
                } else {
                    let bodyString = "{ \"error\": \"unknown request name (\(serviceName)) : \(request.name)\" }"
                    let body = bodyString.data(using: .utf8)
                    moo.sendComplete(MooName.invalidRequest, body: body, message: request)
                }
            } else {
                specs.subscriptions.forEach { s in
                    let subname = s.subscribeName
                    registeredService.subservices[subname]?[moo.mooID] = nil
                    s.end?()
                }
            }
        }

        registeredService.name = serviceName
        return registeredService
    }

    private func periodicScan() {
        scanCount += 1
        logger.log("Periodic scan \(scanCount)")
        guard !isPaired else { return }
        guard scanCount < 0 || scanCount % 6 == 0 else { return }
        sood?.query(serviceId: roonServiceID)
    }

    private func onSoodStart() {
        logger.log("Starting sood")
        sood?.query(serviceId: roonServiceID)
        periodicScanSubscription = Timer.publish(every: 10, on: .current, in: .default)
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.periodicScan()
            }
        scanCount = -1
    }

    private func onSoodMessage(_ message: SoodMessage) {
        logger.log(message)
        guard message.props.serviceId == roonServiceID, let propsUniqueId = message.props.uniqueId else { return }
        guard soodConnections[propsUniqueId] == nil else { return }

        guard var ip = message.from.ip,
              let port = message.props.httpPort?.toInt() else { return }

        let interfaces = NetworkInterfacesProvider.interfaces
        interfaces.forEach { interface in
            if ip == interface.ip {
                ip = "127.0.0.1"
            }
        }

        soodConnections[propsUniqueId] = wsConnect(hostIP: ip, httpPort: UInt16(port), onClose: { [weak self] in
            self?.soodConnections[propsUniqueId] = nil
        }, onError: { [weak self] in
            self?.onError?($0)
        })

        logger.log("Sood connections \(soodConnections)")
    }

    private func onSoodNetwork() {
        logger.log("Sood on network")
        sood?.query(serviceId: roonServiceID)
    }

    private func wsConnect(hostIP: String,
                           httpPort: UInt16,
                           onClose: @escaping () -> Void,
                           onError: @escaping (Error) -> Void) -> Moo {
        logger.log("Sood WS Connect \(hostIP):\(httpPort)")
        let transport = try! MooTransport(host: hostIP, port: httpPort)
        let moo = Moo(transport: transport)

        moo.onOpen = { [weak self] moo in
            guard let self else { return }
            self.logger.log("moo.onOpen")
            moo.sendRequest(name: MooName.info) { [weak self] message in
                guard let self,
                      let data = message?.body,
                      let core: RoonCore = try? JSONDecoder.default.decode(RoonCore.self, from: data) else {
                    return
                }

                if let token = roonSettings.roonState?.tokens[core.coreID] {
                    self.extensionRegInfo.token = token
                }

                let body = try? self.extensionRegInfo.jsonEncoded()
                moo.sendRequest(name: .register, body: body, contentType: .applicationJson) { [weak self] message in
                    guard let self else { return }
                    self.logger.log(".** RoonAPI registered successfully \(String(describing: message))")
                    self.evRegistered(moo: moo, message: message)
                }
            }
        }
        moo.onClose = { [weak self] moo in
            guard let self else { return }
            self.logger.log("moo.onClose")
            self.serviceRequestHandlers.forEach { key, handler in
                handler(moo, nil)
            }
            moo.cleanUp()
            onClose()
        }
        moo.onMessage = { [weak self] moo, message in
            guard let self else { return }
            let body = message.body

            if message.verb == .request {
                let stringBody = body.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                self.logger.log("API 1 <- \(message.verb) \(message.requestID) \(message.service ?? "") / \(message.name) \(stringBody)")
                if let service = message.service,
                    let handler = self.serviceRequestHandlers[service] {
                    handler(moo, message)
                } else {
                    let bodyString = "{ \"error\": \"unknown service: \(message.service ?? "")\" }"
                    moo.sendComplete(.invalidRequest, body: bodyString.data(using: .utf8), message: message)
                }
            } else {
                let stringBody = body.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                self.logger.log("API 2 <- \(message.verb) \(message.requestID) \(message.name) \(stringBody)")
                if !moo.handleMessage(message: message) {
                    moo.close()
                }
            } 
        }
        moo.onError = { [logger] moo, error in
            logger.log("moo.onError")
            onError(error)
        }
        moo.connectWebSocket()
        return moo
    }

    private func evRegistered(moo: Moo, message: MooMessage?) {
        if message == nil {
            // Lost connection
            if let core = moo.core {
                pairingService?.lostCore(core)
                coreLost?(core)
                moo.core = nil
            }
        } else if let message,
                  message.name == .registered {
            if let body = message.body,
               let core = try? JSONDecoder.default.decode(RoonCore.self, from: body) {
                moo.core = core
                var roonState = roonSettings.roonState ?? .init(tokens: [:])
                roonState.tokens[core.coreID] = core.token
                roonSettings.roonState = roonState
                pairingService?.foundCore(core)
                coreFound?(core)
            }
        }
    }

    private func logMessage(optionalServices: [ServiceRegistry],
                            requiredServices: [ServiceRegistry],
                            providedServices: [ServiceRegistry]) -> String {
        var logMessage = "Initializing services\n"
        if !optionalServices.isEmpty {
            logMessage.append("\tOptional: \(optionalServices)\n")
        }
        if !requiredServices.isEmpty {
            logMessage.append("\tRequired: \(requiredServices)\n")
        }
        if !providedServices.isEmpty {
            logMessage.append("\tProvided: \(providedServices)")
        }
        return logMessage
    }
}

extension URL {
    static var configPath: URL? = {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return documentDirectory.appendingPathComponent("config.json")
    }()
}

enum RoonAPIError: Error {
    case unableToInitServices(details: String)
}
