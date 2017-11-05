//
//  SettingsTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest
@testable import MenuNav

class SettingsTests: XCTestCase {
   
    // MARK: - Mock Types
    
    class MockSettingObserver {
        
        var numCallbacks = 0
        var handler: () -> Void = {}
        
        init(setting: Setting<Int>) {
            setting.add(changeObserver: self, selector: #selector(callBack))
        }
        
        @objc func callBack() {
            numCallbacks += 1
            handler()
        }
    }
    
    // MARK: - Setting set / get value
    
    func testSettingSetsIntValueInKeyValueStore() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let setting = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: 0)
        setting.value = 99
        XCTAssertEqual(keyValueStore.dictionary["key"] as? Int, 99)
    }
    
    func testSettingSetsBoolValueInKeyValueStore() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let setting = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: false)
        setting.value = true
        XCTAssertEqual(keyValueStore.dictionary["key"] as? Bool, true)
    }
    
    func testSettingSetsStringValueInKeyValueStore() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let setting = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: "Default")
        setting.value = "New Value"
        XCTAssertEqual(keyValueStore.dictionary["key"] as? String, "New Value")
    }
    
    func testSettingGetsIntValueFromKeyValueStore() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let setting = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: 0)
        keyValueStore.dictionary["key"] = 99
        XCTAssertEqual(setting.value, 99)
    }
    
    func testSettingGetsBoolValueFromKeyValueStore() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let setting = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: false)
        keyValueStore.dictionary["key"] = true
        XCTAssertEqual(setting.value, true)
    }
    
    func testSettingGetsStringValueFromKeyValueStore() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let setting = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: "Default")
        keyValueStore.dictionary["key"] = "New Value"
        XCTAssertEqual(setting.value, "New Value")
    }
    
    // MARK: - Test default value
    
    func testSettingDoesntPersistDefaultValueInKeyValueStore() {
        
        let keyValueStore = DictionaryKeyValueStore()
        _ = Setting(keyValueStore: keyValueStore, key: "key", defaultValue: 100)
        XCTAssertNil(keyValueStore.dictionary["key"])
    }
    
    func testSettingReturnsDefaultIntValue() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(),
                              key: "key",
                              defaultValue: 100)
        XCTAssertEqual(setting.value, 100)
    }
    
    func testSettingReturnsDefaultBoolValue() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(),
                              key: "key",
                              defaultValue: true)
        XCTAssertEqual(setting.value, true)
    }
    
    func testSettingReturnsDefaultStringValue() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(),
                              key: "key",
                              defaultValue: "Default")
        XCTAssertEqual(setting.value, "Default")
    }
    
    // MARK: - Test returns previously set values
    
    func testSettingReturnsPreviouslySetIntValue() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(),
                              key: "key",
                              defaultValue: 100)
        setting.value = 99
        XCTAssertEqual(setting.value, 99)
    }
    
    func testSettingReturnsPreviouslySetBoolValue() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(),
                              key: "key",
                              defaultValue: false)
        setting.value = true
        XCTAssertEqual(setting.value, true)
    }
    
    func testSettingReturnsPreviouslySetStringValue() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(),
                              key: "key",
                              defaultValue: "Default")
        setting.value = "New Value"
        XCTAssertEqual(setting.value, "New Value")
    }
    
    // MARK: - Observers
    
    func testSettingNotifiesObserverWhenValueSet() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(), key: "key", defaultValue: 0)
        let observer = MockSettingObserver(setting: setting)
        setting.value = 99
        XCTAssertEqual(observer.numCallbacks, 1)
    }
    
    func testSettingNotifiesObserverWhenValueSetMultipleTimes() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(), key: "key", defaultValue: 0)
        let observer = MockSettingObserver(setting: setting)
        setting.value = 99
        setting.value = 3
        setting.value = 42
        XCTAssertEqual(observer.numCallbacks, 3)
    }
    
    func testSettingNotifiesMultipleObservers() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(), key: "key", defaultValue: 0)
        
        let observers = (0..<3).map { _ in return MockSettingObserver(setting: setting) }
        setting.value = 99
        setting.value = 2
        XCTAssertEqual(observers.map { $0.numCallbacks }, [2, 2, 2])
    }
    
    func testSettingDoesNotRetainObserver() {
        
        var receivedCallback = false
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(), key: "key", defaultValue: 0)
        var observer: MockSettingObserver? = MockSettingObserver(setting: setting)
        observer!.handler = {
            receivedCallback = true
        }
        observer = nil
        XCTAssertEqual(receivedCallback, false)
    }
    
    func testCallingSettingRemoveObserverRemovesObserver() {
        
        let setting = Setting(keyValueStore: DictionaryKeyValueStore(),
                              key: "key",
                              defaultValue: 0)
        
        let observer = MockSettingObserver(setting: setting)
        
        var receivedCallback = false
        observer.handler = {
            receivedCallback = true
        }
        
        setting.remove(changeObserver: observer)
        setting.value = 99
        XCTAssertFalse(receivedCallback)
    }
    
    func testSettingWillCallLivingObserverButNotDeallocatedObserver() {
        
        var livingObserverReceivedCallback = false
        var deallocatedObserverReceivedCallback = false

        let setting = Setting(keyValueStore: DictionaryKeyValueStore(), key: "key", defaultValue: 0)
        
        let livingObserver = MockSettingObserver(setting: setting)
        livingObserver.handler = {
            livingObserverReceivedCallback = true
        }
        
        var deallocatedObserver: MockSettingObserver? = MockSettingObserver(setting: setting)
        deallocatedObserver?.handler = {
            deallocatedObserverReceivedCallback = true
        }
        deallocatedObserver = nil
        
        setting.value = 99
        
        XCTAssertEqual(livingObserverReceivedCallback, true)
        XCTAssertEqual(deallocatedObserverReceivedCallback, false)
    }
    
}
