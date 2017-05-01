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
    
    // MARK: - File Types
        
    static var fileTypes: [String] {
        
        get {
            let types = userDefaults.object(forKey: #function) as? [String]
            return types ?? []
        }
        set {
            userDefaults.set(newValue, forKey: #function)
            userDefaults.synchronize()
        }
    }
    
    static func addFileType(ext: String) {
    
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
