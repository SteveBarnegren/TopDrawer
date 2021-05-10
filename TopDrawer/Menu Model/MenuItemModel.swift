//
//  MenuModel.swift
//  TopDrawer
//
//  Created by Steven Barnegren on 10/05/2021.
//  Copyright © 2021 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit

struct MenuModel {
    var path: String
    var contents = [MenuItemModel]()
    
    mutating func add(item: MenuItemModel) {
        self.contents.append(item)
    }
}

struct MenuItemModel {
    var title: String
    var path: String
    var image: NSImage?
    var subMenu: MenuModel?
}

extension Directory {
    
    func asMenuItemModel() -> MenuModel {
        
        var menu = MenuModel(path: self.path)
        
        for inner in self.contents {
            
            var item = MenuItemModel(title: inner.menuName, path: inner.path)
            item.image = inner.image
            
            if let innerDir = inner as? Directory, innerDir.contents.count > 0 {
                item.subMenu = innerDir.asMenuItemModel()
            }
            menu.add(item: item)
        }
        
        return menu
    }
}

extension MenuModel {
    
    func convertToNSMenu(target: AnyObject,
                         selector: Selector,
                         openTerminal: Selector,
                         isRootDirectory: Bool) -> NSMenu {
        
        let menu = NSMenu()
        
        for inner in self.contents {
            
            let item = NSMenuItem(title: inner.title, action: selector, keyEquivalent: "")
            item.target = target
            item.representedObject = inner.path
            item.image = inner.image
            
            if let subMenu = inner.subMenu {
                item.submenu = subMenu.convertToNSMenu(target: target,
                                                       selector: selector,
                                                       openTerminal: openTerminal,
                                                       isRootDirectory: false)
            }
            
            menu.addItem(item)
        }
        
        if isRootDirectory == false && Settings.shared.enableTerminalHere.value {
            
            let terminalHereItem = NSMenuItem(title: "Open", action: openTerminal, keyEquivalent: "")
            terminalHereItem.target = target
            terminalHereItem.representedObject = self.path
            let terminalIcon = NSImage(named: "terminalHereMenuIcon")
            terminalIcon?.size = NSSize(width: 20, height: 20)
            terminalHereItem.image = terminalIcon
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(terminalHereItem)
        }
        
        return menu
    }
}



