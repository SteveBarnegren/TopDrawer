//
//  AppDelegate.swift
//  MenuNav
//
//  Created by Steven Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //there is a bug in Xcode that prevents it from recognizing NSSquareStatusItemLength, but since it’s just a constant that’s defined as -2, you just use -2 in it’s place
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(statusBarButtonPressed)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func statusBarButtonPressed() {
        print("Status bar button pressed")
        
        let fileSystem = FileSystem()
        fileSystem.acceptedFileTypes = ["xcodeproj", "xcworkspace"]
        fileSystem.buildFileSystemStructure(atPath: "/Users/stevebarnegren/Documents/PROJECTS")
        
    }
    
}

