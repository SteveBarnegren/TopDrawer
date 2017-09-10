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

// MARK: - Setting

class Setting<T: KeyValueStorable> {
    
    let keyValueStore: KeyValueStore
    let key: String
    let defaultValue: T
    
    init(keyValueStore: KeyValueStore, key: String, defaultValue: T) {
        self.keyValueStore = keyValueStore
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var value: T {
        set {
            switch newValue {
            case let value as String:
                keyValueStore.set(string: value, forKey: key)
            case let value as Bool:
                keyValueStore.set(bool: value, forKey: key)
            case let value as Int:
                keyValueStore.set(int: value, forKey: key)
            default:
                fatalError("The swift compiler should be smart enough to realise that this switch is exaustive")
            }
        }
        get {
            switch T.self {
            case is String.Type:
                return keyValueStore.string(forKey: key) as? T ?? defaultValue
            case is Bool.Type:
                return keyValueStore.bool(forKey: key) as? T ?? defaultValue
            case is Int.Type:
                return keyValueStore.int(forKey: key) as? T ?? defaultValue
            default:
                fatalError("The swift compiler should be smart enough to realise that this switch is exaustive")
            }
        }
    }
}

// MARK: - Settings

class Settings {
    
    // MARK: - Singleton
    
    static let shared = Settings(keyValueStore: UserPreferences())
    
    // MARK: - Properties
    
    let path: Setting<String>
    let shortenPaths: Setting<Bool>
    let followAliases: Setting<Bool>
    let refreshMinutes: Setting<Int>
    
    // MARK: - Init
    
    init(keyValueStore: KeyValueStore) {
        self.path = Setting(keyValueStore: keyValueStore, key: "path", defaultValue: "")
        self.shortenPaths = Setting(keyValueStore: keyValueStore, key: "shortenPaths", defaultValue: true)
        self.followAliases = Setting(keyValueStore: keyValueStore, key: "followAliases", defaultValue: false)
        self.refreshMinutes = Setting(keyValueStore: keyValueStore, key: "refreshMinutes", defaultValue: 10)
    }
}


/*
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
 */
