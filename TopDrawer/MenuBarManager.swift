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
    let rebuildManager = RebuildManager()
    
    // MARK: - Start
    
    func start() {
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(statusBarButtonPressed)
        }
        
        // Show initial menu state
        resetMenu(withMenuModel: nil)
        addPersistentBottomItemsToMenu()
        
        // Build menu
        rebuildManager.addListener(self)
        rebuildManager.needsRebuild = true
        
        // Auto open settings
        if autoOpenSettings || Settings.shared.path.value.isEmpty {
            self.openSettings()
        }
    }
    
    // MARK: - Build NSMenu
    
    func resetMenu(withMenuModel menuModel: MenuModel?) {
                
        if let menu = menuModel {
            statusItem.menu = menu.convertToNSMenu(target: self,
                                                   selector: #selector(menuItemPressed),
                                                   openTerminal: #selector(openTerminalPressed),
                                                   isRootDirectory: true)
            addSeparatorToMenu()
        } else {
            statusItem.menu = NSMenu()
        }
    }
    
    func addReadoutItemToMenu(withTitle title: String) {
        
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        statusItem.menu?.addItem(item)
    }
    
    func addSeparatorToMenu() {
        statusItem.menu?.addItem(NSMenuItem.separator())
    }
    
    func addRefreshItemToMenu() {
        
        if rebuildManager.state == .rebuilding {
            addReadoutItemToMenu(withTitle: "Searching...")
        } else {
            let rebuildItem = NSMenuItem(title: "Rebuild", action: #selector(rebuildItemPressed), keyEquivalent: "")
            rebuildItem.target = self
            statusItem.menu?.addItem(rebuildItem)
        }
    }
    
    func addPersistentBottomItemsToMenu() {
        
        // Add settings item
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        statusItem.menu?.addItem(settingsItem)
        
        // Add quit item
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
    
    @objc func openTerminalPressed(item: NSMenuItem) {
        print("Open Terminal pressed")
        
        guard let path = item.representedObject as? String else {
            print("Unable to obtain path from menu object")
            return
        }
        
        let arguments = ["-a", "Terminal", path]
        Process.launchedProcess(launchPath: "/usr/bin/open", arguments: arguments)
    }
    
    @objc func openSettings() {
        print("Open settings")
        
        let storyboard = NSStoryboard(name: "App", bundle: nil)
        appWindowController = storyboard.instantiateInitialController() as? NSWindowController
        appWindowController?.showWindow(self)
        appWindowController?.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        appWindowController?.window?.makeKeyAndOrderFront(self)
        let viewController = appWindowController?.window?.contentViewController as! PanelViewController
        viewController.configure(withRebuildManager: rebuildManager)
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
    
    func rebuildManagerDidChangeState(state: RebuildManager.State) {
        
        let result = rebuildManager.lastResults
        
        switch result.type {
        case .success:
            resetMenu(withMenuModel: result.menuModel)
            addRefreshItemToMenu()
            addPersistentBottomItemsToMenu()
        case .tookTooLong:
            resetMenu(withMenuModel: result.menuModel)
            addReadoutItemToMenu(withTitle: "Last rebuild failed: took too long")
            addRefreshItemToMenu()
            addPersistentBottomItemsToMenu()
            
        case .invalidRootPath:
            resetMenu(withMenuModel: nil)
            addReadoutItemToMenu(withTitle: "Last rebuild failed: invalid path")
            addPersistentBottomItemsToMenu()
            
        case .noMatchingFiles:
            resetMenu(withMenuModel: nil)
            addReadoutItemToMenu(withTitle: "No matching files")
            addRefreshItemToMenu()
            addPersistentBottomItemsToMenu()
            
        case .noRootPathSet:
            resetMenu(withMenuModel: nil)
            addReadoutItemToMenu(withTitle: "No root path set")
            addPersistentBottomItemsToMenu()
            
        case .unknownError:
            resetMenu(withMenuModel: nil)
            addReadoutItemToMenu(withTitle: "Last rebuild failed: unknown error")
            addRefreshItemToMenu()
            addPersistentBottomItemsToMenu()
            
        case .none:
            resetMenu(withMenuModel: nil)
            addReadoutItemToMenu(withTitle: "Searching...")
            addPersistentBottomItemsToMenu()
        }
    }
  
}
