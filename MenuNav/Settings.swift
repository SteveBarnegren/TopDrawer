//
//  Setting.swift
//  MenuNav
//
//  Created by Steve Barnegren on 29/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit
import ServiceManagement
import IYLoginItem

fileprivate let userDefaults = UserDefaults.standard

class Settings {
    
    // MARK: - Path
    
    static var path: String? {
        get{
            return userDefaults.object(forKey: #function) as? String
        }
        set{
            userDefaults.setValue(newValue, forKey: #function)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Open at login
    
    static var openAtLogin: Bool {
        get {
            return Bundle.main.isLoginItem()
        }
        set {
            
            if newValue == true {
                Bundle.main.addToLoginItems()
            }
            else{
                Bundle.main.removeFromLoginItems()
            }
        }
    }
    
    // MARK: - Only show folders with matching files
    
    static var onlyShowFoldersWithMatchingFiles: Bool {
        get{
            return userDefaults.bool(forKey: #function)
        }
        set{
            userDefaults.setValue(newValue, forKey: #function)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Shorten paths where possible
    
    static var shortenPathsWherePossible: Bool {
        get{
            return userDefaults.bool(forKey: #function)
        }
        set{
            userDefaults.setValue(newValue, forKey: #function)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - File Types
        
    static var fileRules: [FileRule] {
        
        get {
            let types = userDefaults.object(forKey: #function) as? [Dictionary<String, Any>]
            
            if let types = types {
                return types.flatMap{ FileRule(dictionaryRepresentation: $0) }
            }
            else{
                return []
            }
            
        }
        set {
            userDefaults.set(newValue.map{ $0.dictionaryRepresentation }, forKey: #function)
            userDefaults.synchronize()
        }
    }
    
    static func add(rule: FileRule) {
        fileRules = fileRules.appending(rule)
    }
    
    static func removeRule(atIndex index: Int) {
        
        var rules = fileRules
        rules.remove(at: index)
        fileRules = rules
    }
    
    // MARK: - Folder Rules
    
    private static let folderRulesKey = "FolderRulesKey"
    
    static var folderRules: [FolderRule] {
        
        get {
            
            if let array = userDefaults.object(forKey: folderRulesKey) as? [Dictionary<String, Any>] {
                return array.flatMap{ FolderRule(dictionaryRepresentation: $0) }
            }
            else{
                return []
            }
        }
        set {
            userDefaults.set(newValue.map{ $0.dictionaryRepresentation }, forKey: folderRulesKey)
            userDefaults.synchronize()
        }
    }
    
    static func add(folderRule: FolderRule) {
        folderRules = folderRules.appending(folderRule)
    }
    
    static func update(folderRule: FolderRule, atIndex index: Int) {
        
        var rules = folderRules
        rules[index] = folderRule
        folderRules = rules 
    }
    
}
