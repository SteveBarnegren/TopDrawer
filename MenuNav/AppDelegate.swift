//
//  AppDelegate.swift
//  MenuNav
//
//  Created by Steven Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBSwiftUtils

let autoOpenSettings = true

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let menuBarManager = MenuBarManager.shared
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
        menuBarManager.start()
    }
        
}


