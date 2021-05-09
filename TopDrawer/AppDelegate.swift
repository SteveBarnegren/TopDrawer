//
//  AppDelegate.swift
//  MenuNav
//
//  Created by Steven Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBSwiftUtils
import AppKit

let autoOpenSettings = false

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let menuBarManager = MenuBarManager()
    static let launcherAppId = "com.stevebarnegren.topdrawerlauncher"
    static let launchAtLoginUserDefaultKey = "launchAtLogin"
    private let appUpdater = AppUpdater.shared
  
    func applicationDidFinishLaunching(_ aNotification: Notification) {
      
        guard NSClassFromString("XCTestCase") == nil else {
            print("AppDelegate preventing app from launching during tests")
            return
        }
      
        NSApp.activate(ignoringOtherApps: true)
        menuBarManager.start()
    }
    
    @IBAction private func checkForUpdates(sender: Any) {
        appUpdater.checkForUpdates()
    }
}
