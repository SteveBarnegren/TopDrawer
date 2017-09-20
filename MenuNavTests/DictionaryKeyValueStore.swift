//
//  DictionaryKeyValueStore.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

class DictionaryKeyValueStore: KeyValueStore {
    
    var dictionary = [String: Any]()
    
    func set(value: Any, forKey key: String) {
        dictionary[key] = value
    }
    
    func value(forKey key: String) -> Any? {
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
