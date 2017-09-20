//
//  MenuBarManager.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit

class MenuBarManager {
        
    var appWindowController: NSWindowController?
    let statusItem = NSStatusBar.system.statusItem(withLength: -2)
    let rebuildManager = RebuildManager.shared
    
    // MARK: - Start
    
    func start() {
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
            button.action = #selector(statusBarButtonPressed)
        }
        
        // Build menu
        showRebuldingMenu()
        rebuildManager.addListener(self)
        rebuildManager.needsRebuild = true
        
        // Auto open settings
        if autoOpenSettings {
            self.openSettings()
        }
    }
    
    // MARK: - Show Menu States
    
    func showSetupMenu() {
        
        // Add setup item
        let setupItem = NSMenuItem(title: "Setup (No root dir set)", action: #selector(openSettings), keyEquivalent: "")
        setupItem.target = self
        let setupMenu = NSMenu()
        setupMenu.addItem(setupItem)
        statusItem.menu = setupMenu
        
        // Add quit item
        addQuitItemToStatusMenu()
    }
    
    func showFileStructureMenu(withRootDirectory rootDirectory: Directory) {
        
        statusItem.menu = rootDirectory.convertToNSMenu(target: self, selector: #selector(menuItemPressed))
        
        // Add rebuild item
        statusItem.menu?.addItem(NSMenuItem.separator())
        let rebuildItem = NSMenuItem(title: "Rebuild", action: #selector(rebuildItemPressed), keyEquivalent: "")
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
        quitItem.target = self
        statusItem.menu?.addItem(quitItem)
    }
    
    // MARK: - Actions
    
    @objc func statusBarButtonPressed() {
        print("Status bar button pressed")
    }
    
    @objc func menuItemPressed(item: NSMenuItem) {
        print("Menu item pressed")
        
        guard let path = item.representedObject as? String else {
            print("Unable to obtain path from menu object")
            return
        }
        
        NSWorkspace.shared.openFile(path)
    }
    
    @objc func openSettings() {
        print("Open settings")
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "App"), bundle: nil)
        appWindowController = storyboard.instantiateInitialController() as? NSWindowController
        appWindowController?.showWindow(self)
        appWindowController?.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        appWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    @objc func rebuildItemPressed() {
        rebuildManager.needsRebuild = true
    }
    
    @objc func quit() {
        NSApp.terminate(self)
    }

}

// MARK: - RebuildManagerListener
extension MenuBarManager: RebuildManagerListener {
    
    func rebuildManagerDidFailRebuildDueToNoRootPathSet() {
        showSetupMenu()
    }
    
    func rebuildManagerDidRebuild(directory: Directory) {
        showFileStructureMenu(withRootDirectory: directory)
    }
    
    func rebuildManagerDidChangeState(state: RebuildManager.State) {
    }
}

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
