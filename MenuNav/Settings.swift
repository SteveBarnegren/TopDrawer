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
    
    // MARK: - Shorten paths
    
    static var shortenPaths: Bool {
        get{
            return userDefaults.bool(forKey: #function)
        }
        set{
            userDefaults.setValue(newValue, forKey: #function)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Follow Aliases
    
    static var followAliases: Bool {
        get {
            return userDefaults.bool(forKey: #function)
        }
        set {
            userDefaults.setValue(newValue, forKey: #function)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Refrresh Interval
    
    static var refreshMinutes: Int {
        return 1
    }
}
