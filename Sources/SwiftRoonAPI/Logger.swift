//
//  Logger.swift
//  RoonMiniPlayer
//
//  Created by Alejandro Maya on 5/12/22.
//

import Foundation
import os.log

class Logger {

    var enabled: Bool
    private lazy var logger = os.Logger()

    init(enabled: Bool) {
        self.enabled = enabled
    }

    func log(_ message: String) {
        if enabled {
            self.logger.log(level: .debug, "\(message)")
        }
    }

}
