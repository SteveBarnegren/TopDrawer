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
    
    static let shared = MenuBarManager()
    
    var appWindowController: NSWindowController?
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    var isRebuilding = false {
        didSet{
            if isRebuilding == true {
                showRebuldingMenu()
            }
            else{
                print("STOP")
            }
        }
    }
    
    var needsRebuild = false {
        didSet{
            if needsRebuild && !isRebuilding {
                buildMenuIfNeeded()
            }
            else if needsRebuild && isRebuilding {
                workItem!.cancel()
            }
        }
    }
    
    var workItem: DispatchWorkItem?
    
    // MARK: - Start
    
    func start()  {
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = #selector(statusBarButtonPressed)
        }
        
        // Build menu
        needsRebuild = true
        
        // Auto open settings
        if autoOpenSettings {
            self.openSettings()
        }
    }
    
    // MARK: - Build menu
    
    func buildMenuIfNeeded() {
        if needsRebuild {
            needsRebuild = false
            buildMenu()
        }
    }
    
    func buildMenu() {
        
        print("Rebuilding menu")
        self.workItem = nil
        isRebuilding = true
        
        // Get the file structure
        var options = FileStructureBuilder.Options()
        
        if Settings.shortenPaths {
            options.update(with: .shortenPaths)
        }
        
        if Settings.followAliases {
            options.update(with: .followAliases)
        }
        
        let builder = FileStructureBuilder(fileReader: FileManager.default,
                                           fileRules: FileRule.ruleLoader.rules,
                                           folderRules: FolderRule.ruleLoader.rules,
                                           options: options)
        
        guard let path = Settings.path else {
            showSetupMenu()
            return
        }
        
        workItem = DispatchWorkItem { [weak self] in
            
            builder.isCancelledHandler = {
                if let item = self?.workItem, item.isCancelled {
                    print("Cancelled building menu")
                    return true
                }
                else{
                    return false
                }
            }
            
            guard let rootDirectory = builder.buildFileSystemStructure(atPath: path) else {
                
                guard let item = self?.workItem else {
                    return
                }
                
                if item.isCancelled {
                    self?.isRebuilding = false
                    self!.buildMenuIfNeeded()
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    print("Finished Building menu")
                    self?.isRebuilding = false
                    self!.showSetupMenu()
                })
                return
            }
            
            guard let item = self?.workItem else {
                self?.isRebuilding = false
                return
            }
            
            if item.isCancelled {
                self?.isRebuilding = false
                self!.buildMenuIfNeeded()
                return
            }
            
            DispatchQueue.main.async(execute: {
                print("Finished Building menu")
                self?.isRebuilding = false
                self?.showFileStructureMenu(withRootDirectory: rootDirectory)
            })
        }
        
        DispatchQueue.global().async(execute: workItem!)
        
    }
    
    // MARK: - Show Menu States
    
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
        
        NSWorkspace.shared().openFile(path)
    }
    
    @objc func openSettings() {
        print("Open settings")
        
        let storyboard = NSStoryboard(name: "App", bundle: nil)
        appWindowController = storyboard.instantiateInitialController() as? NSWindowController
        appWindowController?.showWindow(self)
        appWindowController?.window?.level = Int(CGWindowLevelForKey(.floatingWindow))
        appWindowController?.window?.makeKeyAndOrderFront(self)
    }
    
    @objc func rebuildItemPressed() {
        needsRebuild = true
    }
    
    @objc func quit() {
        NSApp.terminate(self)
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

