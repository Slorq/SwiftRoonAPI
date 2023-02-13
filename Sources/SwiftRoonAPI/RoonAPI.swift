//
//  RoonAPI.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 5/12/22.
//

import class Combine.AnyCancellable
import Foundation
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

    private let logger: Logger
    private var moo: Moo!
    private var options: RoonOptions
    private var extensionRegInfo: RoonExtensionRegInfo
    private var periodicScanSubscription: AnyCancellable?
    private var sood: Sood?
    private var scanCount = 0
    private var soodConnections: [String: Moo] = [:]
    private var pairedCore: RoonCore?
    private var isPaired = false
    private var serviceRequestHandlers: [String: (Moo, MooMessage?) -> Void] = [:]
    private var pairingService: PairingServiceRegistry?
    private var servicesOpts: ([ServiceRegistry], [ServiceRegistry], [ServiceRegistry])?
    public var coreFound: RoonCoreCompletionHandler?
    public var coreLost: RoonCoreCompletionHandler?
    public var corePaired: RoonCoreCompletionHandler?
    public var coreUnpaired: RoonCoreCompletionHandler?
    public var onError: RoonErrorCompletionHandler?

    public init(options: RoonOptions) {
        self.logger = .init(enabled: true)
        self.options = options
        self.extensionRegInfo = .init(options: options)

        super.init()
    }

    public func startDiscovery() {
        guard sood == nil else { return }
        let sood = Sood()
        self.sood = sood
        sood.onMessage = { [weak self] in self?.onSoodMessage($0) }
        sood.onNetwork = { [weak self] in self?.onSoodNetwork() }
        sood.start { [weak self] in self?.onSoodStart() }
    }

    public func initServices(optionalServices: [ServiceRegistry] = [],
                      requiredServices: [ServiceRegistry] = [],
                      providedServices: [ServiceRegistry] = []) throws {
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
                let bodyString = (self?.pairedCore?.coreID).map { "{\"paired_core_id\":\($0)}" }
                moo.sendContinue(.subscribed, body: bodyString?.data(using: .utf8), message: request)
            }
            let getPairing: (Moo, MooMessage) -> Void = { [weak self] moo, request in
                let bodyString = (self?.pairedCore?.coreID).map { "{\"paired_core_id\":\($0)}" }
                moo.sendComplete(.success, body: bodyString?.data(using: .utf8), message: request)
            }
            let pair: (Moo, MooMessage) -> Void = { [weak self] moo, request in
                guard let self,
                      let body = request.body,
                      let core = try? JSONDecoder().decode(RoonCore.self, from: body) else {
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
                    RoonSettings.pairedCoreID = core.coreID

                    self.pairedCore = core
                    self.isPaired = true
                    let bodyString = "{ \"paired_core_id\": \"\(core.coreID)\" }"
                    bodyString.data(using: .utf8).map {
                        service.sendContinueAll(moo: core.moo, subtype: "subscribe_pairing", name: "Changed", body: $0)
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
        let registeredService = RegisteredService()

        specs.subscriptions.forEach { s in
            let subname = s.subscribeName
            registeredService.subtypes[subname] = [:]
            specs.methods[subname] = { moo, request in
                guard let body = request.body,
                      let subscriptionBody = try? JSONDecoder().decode(SubscriptionBody.self, from: body) else {
                    assertionFailure("Unable to decode subscriptionBody")
                    return
                }

                let subscriptionMessageHandler = SubscriptionMessageHandler(message: request)
                let originalSendComplete = subscriptionMessageHandler.sendComplete
                subscriptionMessageHandler.sendComplete = { moo, name, body, message in
                    originalSendComplete(moo, name, body, message)
                    registeredService.subtypes[subname]?[moo.mooID]?[subscriptionBody.subscriptionKey] = nil
                }
                s.start(moo, request)
                if registeredService.subtypes[subname]?[moo.mooID] == nil {
                    registeredService.subtypes[subname]?[moo.mooID] = [:]
                }
                registeredService.subtypes[subname]?[moo.mooID]?[subscriptionBody.subscriptionKey] = subscriptionMessageHandler
            }

            specs.methods[s.unsubscribeName] = { moo, request in
                guard let body = request.body,
                      let subscriptionBody = try? JSONDecoder().decode(SubscriptionBody.self, from: body) else {
                    assertionFailure("Unable to decode subscriptionBody")
                    return
                }

                registeredService.subtypes[subname]?[moo.mooID]?[subscriptionBody.subscriptionKey] = nil
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
                    moo.sendComplete(.invalidRequest, body: body, message: request)
                }
            } else {
                specs.subscriptions.forEach { s in
                    let subname = s.subscribeName
                    registeredService.subtypes[subname]?[moo.mooID] = nil
                    s.end?()
                }
            }
        }

        registeredService.name = serviceName
        return registeredService
    }

    private func periodicScan() {
        scanCount += 1
        guard !isPaired else { return }
        guard scanCount < 0 || scanCount % 6 == 0 else { return }
        sood?.query(serviceId: roonServiceID)
    }

    private func onSoodStart() {
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
        guard message.props.serviceId == roonServiceID, let propsUniqueId = message.props.uniqueId else { return }
        guard soodConnections[propsUniqueId] == nil else { return }

        guard var ip = message.from.ip,
              let port = message.props.httpPort?.toInt() else { return }

        let networkInterfaces = SCNetworkInterfaceCopyAll() as Array
        (networkInterfaces as? [SCNetworkInterface])?.forEach {
            guard let bsdName = SCNetworkInterfaceGetBSDName($0) else { return }
            guard ip == getIPAddress(for: bsdName as String) else { return }
            ip = "127.0.0.1"
        }

        soodConnections[propsUniqueId] = wsConnect(hostIP: ip, httpPort: UInt16(port), onClose: { [weak self] in
            self?.soodConnections[propsUniqueId] = nil
        }, onError: { [weak self] in
            self?.onError?($0)
        })

        print(".** soodConnections \(soodConnections)")
    }

    private func onSoodNetwork() {
        sood?.query(serviceId: roonServiceID)
    }

    private func wsConnect(hostIP: String,
                           httpPort: UInt16,
                           onClose: @escaping () -> Void,
                           onError: @escaping (Error) -> Void) -> Moo {
        let transport = try! Transport(host: hostIP, port: httpPort, logger: .init(enabled: false))
        let moo = Moo(transport: transport, logger: .init(enabled: true))

        moo.onOpen = { [weak self] moo in
            guard let self else { return }
            self.logger.log("moo.onOpen")
            moo.sendRequest(name: .info) { [weak self] message in
                guard let self,
                      let data = message?.body,
                      let core: RoonCore = try? JSONDecoder().decode(RoonCore.self, from: data) else {
                    return
                }

                if let token = RoonSettings.roonState?.tokens[core.coreID] {
                    self.extensionRegInfo.token = token
                }

                let body = try! JSONEncoder().encode(self.extensionRegInfo)
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
                    moo.closeTransport()
                }
            }
        }
        moo.onError = { [weak logger] moo, error in
            logger?.log("moo.onError")
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
               let core = try? JSONDecoder().decode(RoonCore.self, from: body) {
                moo.core = core
                var roonState = RoonSettings.roonState ?? .init(tokens: [:])
                roonState.tokens[core.coreID] = core.token
                RoonSettings.roonState = roonState
                pairingService?.foundCore(core)
                coreFound?(core)
            }
        }
    }

    private func getIPAddress(for bsdName: String) -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == bsdName {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
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
