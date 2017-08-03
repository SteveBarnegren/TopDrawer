//
//  FileRuleBuilder.swift
//  MenuNav
//
//  Created by Steve Barnegren on 29/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

/*
 File Rule is pretty strict, and is only constructable with the complete constraints to describe the rule.
 FileRuleConstructor can hold all of the information to construct a rule, but will only return nil if a rule cannot be constructed from the provided information
 */

class FileRuleConstructor {
    
    var itemName: String?
    var itemExtension: String?
    var filter: FileRule.Filter
    
    init() {
        
        filter = .include
    }
    
    init(rule: FileRule) {
        
        filter = rule.filter
        
        switch rule.target {
        case let .matchingName(name):
            itemName = name
        case let .matchingExtension(ext):
            itemExtension = ext
        case let .matchingNameAndExtension(name, ext):
            itemName = name
            itemExtension = ext
        }
    }
    
    // MARK: - Generate Rule
    
    var canMakeRule: Bool {
        
        if let _ = rule {
            return true
        }
        else {
            return false
        }
    }
    
    var rule: FileRule? {
        
        var target: FileRule.Target
        
        switch (itemName, itemExtension) {
        case let (.some(name), .some(ext)):
            target = .matchingNameAndExtension(name: name, ext: ext)
        case let (.some(name), nil):
            target = .matchingName(name)
        case let (nil, .some(ext)):
            target = .matchingExtension(ext)
        default:
            return nil
        }
        
        return FileRule(target: target, filter: filter)
    }
}
