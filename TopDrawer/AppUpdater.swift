//
//  AppUpdater.swift
//  TopDrawer
//
//  Created by Steven Barnegren on 09/05/2021.
//  Copyright © 2021 SteveBarnegren. All rights reserved.
//

import Foundation
import Sparkle


class AppUpdater {
    
    static let shared = AppUpdater()
    
    private let updater = SUUpdater()
    
    func checkForUpdates() {
        updater.checkForUpdates(self)
    }
}
