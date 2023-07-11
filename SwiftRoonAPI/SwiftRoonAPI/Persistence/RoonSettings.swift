//
//  RoonSettings.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/02/23.
//

import Foundation

struct RoonSettings {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var roonState: RoonAuthorizationState? {
        get { userDefaults.roonState }
        set { userDefaults.roonState = newValue }
    }

    var pairedCoreID: String? {
        get { userDefaults.pairedCoreID }
        set { userDefaults.pairedCoreID = newValue }
    }
}

private extension UserDefaults {

    var roonState: RoonAuthorizationState? {
        get { (try? decodedValue(forKey: #function)) }
        set { try? setEncodedValue(newValue, forKey: #function) }
    }

    var pairedCoreID: String? {
        get { string(forKey: #function) }
        set { setValue(newValue, forKey: #function) }
    }

}

private extension UserDefaults {

    private func decodedValue<T: Codable>(forKey key: String) throws -> T? {
        guard let storedData = value(forKey: key) as? Data else {
            return nil
        }

        return try JSONDecoder.default.decode(T.self, from: storedData)
    }

    private func setEncodedValue<T: Codable>(_ value: T, forKey key: String) throws {
        let encodedData = try value.jsonEncoded()
        setValue(encodedData, forKey: key)
    }
}
