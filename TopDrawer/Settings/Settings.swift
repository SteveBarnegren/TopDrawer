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
import LaunchAtLogin

// MARK: - Setting

class Setting<T: KeyValueStorable> {
    
    // MARK: - Types
    
    class Observer {
        weak var object: AnyObject?
        let selector: Selector
        
        init(object: AnyObject, selector: Selector) {
            self.object = object
            self.selector = selector
        }
    }
    
    // MARK: - Properties
    
    let keyValueStore: KeyValueStore
    let key: String
    let defaultValue: T
    var observers = [Observer]()
    
    // MARK: - Init
    
    init(keyValueStore: KeyValueStore, key: String, defaultValue: T) {
        self.keyValueStore = keyValueStore
        self.key = key
        self.defaultValue = defaultValue
    }
    
    // MARK: - Set / Get value
    
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
            
            sendChangeEvent()
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
    
    // MARK: - Manage Observers
    
    func add(changeObserver: AnyObject, selector: Selector) {
        let observer = Observer(object: changeObserver, selector: selector)
        observers.append(observer)
    }
    
    func remove(changeObserver observerToRemove: AnyObject) {
        observers = observers.filter { $0.object !== observerToRemove }
    }
    
    private func sendChangeEvent() {
        
        observers = observers.filter { $0.object != nil }
        observers.forEach {
            _ = $0.object?.perform($0.selector)
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
    let enableTerminalHere: Setting<Bool>
    let refreshMinutes: Setting<Int>
    let timeout: Setting<Int>
    
    var launchAtLogin: Bool {
        get { LaunchAtLogin.isEnabled }
        set { LaunchAtLogin.isEnabled = newValue }
    }
    
    // MARK: - Init
    
    init(keyValueStore: KeyValueStore) {
        self.path = Setting(keyValueStore: keyValueStore, key: "path", defaultValue: "")
        self.shortenPaths = Setting(keyValueStore: keyValueStore, key: "shortenPaths", defaultValue: true)
        self.followAliases = Setting(keyValueStore: keyValueStore, key: "followAliases", defaultValue: false)
        self.enableTerminalHere = Setting(keyValueStore: keyValueStore, key: "enableTerminalHere", defaultValue: false)
        self.refreshMinutes = Setting(keyValueStore: keyValueStore, key: "refreshMinutes", defaultValue: 30)
        self.timeout = Setting(keyValueStore: keyValueStore, key: "timeout", defaultValue: 120)
    }
}
