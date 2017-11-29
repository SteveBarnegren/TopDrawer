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

let autoOpenSettings = true

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let menuBarManager = MenuBarManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //        if let bundle = Bundle.main.bundleIdentifier {
        //            UserDefaults.standard.removePersistentDomain(forName: bundle)
        //        }
        //        return
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "RUNNING_TESTS") == true {
            return
        }
        
        NSApp.activate(ignoringOtherApps: true)
        menuBarManager.start()
    }
}
