//
//  FolderRule.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

public struct FolderRule: Rule {
    
    static let storageKey = "FolderRules"
       
    // MARK: - Properties
    
    let conditions: [FolderCondition]
    
    var numberOfConditions: Int {
        return conditions.count
    }
    
    // MARK: - Init
    
    init(conditions: [Condition]) {
        self.conditions = conditions
    }
    
    // MARK: - Matching
    
    func excludes(directory: Directory) -> Bool {
        
        for condition in conditions {
            if !condition.matches(directory: directory) {
                return false
            }
        }
        return true
    }
    
    // MARK: - Make Decision Tree
    
    static func makeDecisionTree() -> DecisionNode<FolderCondition> {
        return folderConditionDecisionTree()
    }
}

// MARK: - DictionaryRepresentable
extension FolderRule: DictionaryRepresentable {
    
    struct Keys {
        static let Conditions = "Conditions"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard let conditionsArray = dictionary[Keys.Conditions] as? Array<Dictionary<String, Any>> else {
            return nil
        }
        
        let conditions = conditionsArray.flatMap{ Condition(dictionaryRepresentation: $0) }
        if conditions.count < 1 {
            print("No conditions found")
            return nil;
        }
        
        self.init(conditions: conditions)
    }
    
    var dictionaryRepresentation: Dictionary<String, Any> {
        
        var dictionary = Dictionary<String, Any>()
        dictionary[Keys.Conditions] = conditions.map{ $0.dictionaryRepresentation }
        return dictionary
    }
}
