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
    
    var appWindowController: NSWindowController?

    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    var isRebuilding = false {
        didSet{
            if isRebuilding == true {
                showRebuldingMenu()
            }
        }
    }
    
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
        
        isRebuilding = true
        
        // Get the file structure
        let fileSystem = FileSystem()
        fileSystem.acceptedFileTypes = ["xcodeproj", "xcworkspace"]
        
        guard let path = Settings.path else {
            showSetupMenu()
            return
        }
        
        DispatchQueue.global().async {
            
            guard let rootDirectory = fileSystem.buildFileSystemStructure(atPath: path) else {
                
                DispatchQueue.main.async(execute: {
                    self.showSetupMenu()
                })
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.showFileStructureMenu(withRootDirectory: rootDirectory)
            })
        }
        
    }
    
    func showSetupMenu() {
        
        isRebuilding = false
        
        let setupItem = NSMenuItem(title: "Setup (No root dir set)", action: #selector(openSettings), keyEquivalent: "")
        let setupMenu = NSMenu()
        setupMenu.addItem(setupItem)
        statusItem.menu = setupMenu        
    }
    
    func showFileStructureMenu(withRootDirectory rootDirectory: Directory) {
        
        isRebuilding = false
        
        statusItem.menu = rootDirectory.convertToNSMenu(target: self, selector: #selector(menuItemPressed))
        
        // Add rebuild item
        statusItem.menu?.addItem(NSMenuItem.separator())
        let rebuildItem = NSMenuItem(title: "Rebuild", action: #selector(rebuild), keyEquivalent: "")
        rebuildItem.target = self
        statusItem.menu?.addItem(rebuildItem)
        
        // Add settings item
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        statusItem.menu?.addItem(settingsItem)
    }
    
    func showRebuldingMenu() {
        
        isRebuilding = false
        
        let rebuildingItem = NSMenuItem(title: "Rebuilding... (please wait)", action: nil, keyEquivalent: "")
        let menu = NSMenu()
        menu.addItem(rebuildingItem)
        statusItem.menu = menu
    }
    
    // MARK: - Actions
    
    func menuItemPressed(item: NSMenuItem) {
        print("Menu item pressed")
        
        guard let path = item.representedObject as? String else {
            print("Unable to obtain path from menu object")
            return
        }
        
        NSWorkspace.shared().openFile(path)
    }
    
    func rebuild() {
        print("Rebuild menu")
        buildMenu()
    }
    
    func openSettings() {
        print("Open settings")
        
        let storyboard = NSStoryboard(name: "App", bundle: nil)
        appWindowController = storyboard.instantiateInitialController() as? NSWindowController
        appWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Convert Directory to NSMenu

extension Directory {
    
    func convertToNSMenu(target: AnyObject, selector: Selector) -> NSMenu {

        let menu = NSMenu()
        
        for inner in self.contents {
            
            let item = NSMenuItem(title: inner.menuName, action: selector, keyEquivalent: "")
            item.target = target
            item.representedObject = inner.path
            item.image = inner.image
            
            if let innerDir = inner as? Directory, innerDir.contents.count > 0 {
                item.submenu = innerDir.convertToNSMenu(target: target, selector: selector)
            }
            
            menu.addItem(item)
        }
        
        return menu
    }
}

