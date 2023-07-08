//
//  RoonSettings.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 6/02/23.
//

import Foundation

struct RoonSettings {

    static var roonState: RoonAuthorizationState? {
        get { UserDefaults.standard.roonState }
        set { UserDefaults.standard.roonState = newValue }
    }

    static var pairedCoreID: String? {
        get { UserDefaults.standard.pairedCoreID }
        set { UserDefaults.standard.pairedCoreID = newValue }
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
