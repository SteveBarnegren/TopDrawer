//
//  AppDelegate.swift
//  MenuNav
//
//  Created by Steven Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBSwiftUtils

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var appWindowController: NSWindowController?

    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    var isRebuilding = false {
        didSet{
            if isRebuilding == true {
                showRebuldingMenu()
                print("Started Rebuilding menu")
            }
            else{
                print("Finished Rebuilding menu")
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSApp.activate(ignoringOtherApps: true)
        
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
        var options = FileStructureBuilder.Options()
        
        if Settings.onlyShowFoldersWithMatchingFiles {
            options.update(with: .removeEmptyFolders)
        }
        
        if Settings.shortenPathsWherePossible {
            options.update(with: .shortenPaths)
        }
        
        let builder = FileStructureBuilder(fileReader: FileManager.default,
                                           rules: Settings.fileRules,
                                           options: options)
        
        guard let path = Settings.path else {
            showSetupMenu()
            return
        }
        
        DispatchQueue.global().async {
            
            guard let rootDirectory = builder.buildFileSystemStructure(atPath: path) else {
                
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
        
        // Add setup item
        let setupItem = NSMenuItem(title: "Setup (No root dir set)", action: #selector(openSettings), keyEquivalent: "")
        let setupMenu = NSMenu()
        setupMenu.addItem(setupItem)
        statusItem.menu = setupMenu
        
        // Add quit item
        addQuitItemToStatusMenu()
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
        
        // Add quit item
        addQuitItemToStatusMenu()
    }
    
    func showRebuldingMenu() {
        
        isRebuilding = false
        
        // Add rebuilding item
        let rebuildingItem = NSMenuItem(title: "Rebuilding... (please wait)", action: nil, keyEquivalent: "")
        let menu = NSMenu()
        menu.addItem(rebuildingItem)
        statusItem.menu = menu
        
        // Add quit item
        addQuitItemToStatusMenu()
    }
    
    func addQuitItemToStatusMenu() {
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "")
        statusItem.menu?.addItem(quitItem)
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
        appWindowController?.window?.level = Int(CGWindowLevelForKey(.floatingWindow))
        appWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    func quit() {
        NSApp.terminate(self)
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

