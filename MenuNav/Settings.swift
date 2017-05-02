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

    
    // MARK: - File Types
        
    static var fileTypes: [FileType] {
        
        get {
            let types = userDefaults.object(forKey: #function) as? [String]
            
            if let types = types {
                return types.flatMap{ FileType(stringRepresentation: $0) }
            }
            else{
                return []
            }
            
        }
        set {
            userDefaults.set(newValue.map{ $0.stringRepresentation() }, forKey: #function)
            userDefaults.synchronize()
        }
    }
    
    static func addFileType(ext: FileType) {
    
        var types = fileTypes
        types.append(ext)
        fileTypes = types
    }
    
    static func removeFileType(atIndex index: Int) {
        
        var types = fileTypes
        types.remove(at: index)
        fileTypes = types
    }
}
