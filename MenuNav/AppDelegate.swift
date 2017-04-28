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

    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(statusBarButtonPressed)
        }
        
        // Build menu
        buildMenu()
    }
    
    func statusBarButtonPressed() {
        print("Status bar button pressed")
    }
    
    // MARK: - Build menu
    
    func buildMenu() {
        
        // Get the file structure
        let fileSystem = FileSystem()
        fileSystem.acceptedFileTypes = ["xcodeproj", "xcworkspace"]
        let rootDirectory = fileSystem.buildFileSystemStructure(atPath: "/Users/stevebarnegren/Documents/PROJECTS")
        
        
        
        
        
        
        
        // Build the menu
//        let menu = NSMenu()
//        let item = NSMenuItem(title: "Test menu", action: #selector(menuPressed), keyEquivalent: "")
//        item.target = self
//        menu.addItem(item)
//        
//        let innerMenu = NSMenu()
//        let innerMenuItem = NSMenuItem(title: "inner item", action: #selector(innerItemPressed), keyEquivalent: "")
//        innerMenuItem.target = self
//        innerMenu.addItem(innerMenuItem)
//        item.submenu = innerMenu
        
        statusItem.menu = rootDirectory.convertToNSMenu()

    }
}


extension Directory {
    
    func convertToNSMenu() -> NSMenu {

        let menu = NSMenu()
        
        for inner in self.contents {
            
            let item = NSMenuItem(title: inner.name, action: nil, keyEquivalent: "")
            
            if let innerDir = inner as? Directory {
                item.submenu = innerDir.convertToNSMenu()
            }
            
            menu.addItem(item)
        }
        
        return menu
    }
}

