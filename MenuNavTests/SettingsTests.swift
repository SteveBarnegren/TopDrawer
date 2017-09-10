//
//  SettingsTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

class SettingsTests: XCTestCase {
   
    // MARK: - Mock Types
    
    class KeyValueStoreMock: KeyValueStore {
        
        var dictionary = [String:KeyValueStorable]()
        
        func value(forKey key: String) -> KeyValueStorable? {
            return dictionary[key]
        }
        
        func set(bool: Bool, forKey key: String) {
            dictionary[key] = bool
        }
        
        func bool(forKey key: String) -> Bool? {
            return dictionary[key] as? Bool
        }
        
        func set(string: String, forKey key: String) {
            dictionary[key] = string
        }
        
        func string(forKey key: String) -> String? {
            return dictionary[key] as? String
        }
        
        func set(int: Int, forKey key: String) {
            dictionary[key] = int
        }
        
        func int(forKey key: String) -> Int? {
            return dictionary[key] as? Int
        }
    }

    // MARK: - Tests
    
    func testSettingSetsValueInKeyValueStore() {
        
        let keyValueStore = KeyValueStoreMock()
        let setting = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: 0)
        setting.value = 99
        XCTAssertEqual(keyValueStore.dictionary["key"] as? Int, 99)
    }
    
    func testSettingDoesSetDefaultValueInKeyValueStore() {
        
        let keyValueStore = KeyValueStoreMock()
        let _ = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: 100)
        XCTAssertNil(keyValueStore.dictionary["key"])
    }
    
    func testSettingReturnsDefaultValue() {
        
        let setting = Setting(keyValueStore: KeyValueStoreMock(), key: "key", defaultValue: 100)
        XCTAssertEqual(setting.value, 100)
    }
    
    func testSettingReturnsPreviouslySetValue() {
        
        let setting = Setting(keyValueStore: KeyValueStoreMock(), key: "key", defaultValue: 100)
        setting.value = 99
        XCTAssertEqual(setting.value, 99)
    }
    

}
