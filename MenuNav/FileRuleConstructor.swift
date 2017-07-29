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
    
    enum TargetType {
        case files
        case folders
    }
    
    var itemName: String?
    var itemExtension: String?
    var filter: FileRule.Filter
    var targetType: TargetType
    
    init() {
        
        filter = .include
        targetType = .files
    }
    
    init(rule: FileRule) {
        
        itemName = rule.itemName
        itemExtension = rule.itemExtension
        filter = rule.filter
        
        switch rule.target {
        case .files(_, _):
            targetType = .files
        case .folders(_):
            targetType = .folders
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
        switch targetType {
        case .files:
            
            if itemName == nil && itemExtension == nil {
                return nil
            }
            else{
                target = .files(name: itemName, ext: itemExtension)
            }
            
        case .folders:
            
            if let name = itemName {
                target = .folders(name: name)
            }
            else{
                return nil
            }
        }
        
        return FileRule(target: target, filter: filter)
    }
    
    
    
}
