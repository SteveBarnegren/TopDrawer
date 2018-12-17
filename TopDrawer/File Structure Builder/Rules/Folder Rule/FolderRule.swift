//
//  FolderRule.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

struct FolderRule: Rule {
    
    static let storageKey = "FolderRules"
       
    // MARK: - Properties
    
    let conditions: [FolderCondition]
    
    var numberOfConditions: Int {
        return conditions.count
    }
    
    // MARK: - Init
    
    init(conditions: [FolderCondition]) {
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

// MARK: - Equtable

extension FolderRule: Equatable {
    
    static func == (lhs: FolderRule, rhs: FolderRule) -> Bool {
        return lhs.conditions == rhs.conditions
    }
}

// MARK: - DictionaryRepresentable
extension FolderRule: DictionaryRepresentable {
    
    struct Keys {
        static let Conditions = "Conditions"
    }
    
    init?(dictionaryRepresentation dictionary: [String: Any]) {
        
        guard let conditionsArray = dictionary[Keys.Conditions] as? [[String: Any]] else {
            return nil
        }
        
        let conditions = conditionsArray.flatMap { Condition(dictionaryRepresentation: $0) }
        if conditions.count < 1 {
            print("No conditions found")
            return nil
        }
        
        self.init(conditions: conditions)
    }
    
    var dictionaryRepresentation: [String: Any] {
        
        var dictionary = [String: Any]()
        dictionary[Keys.Conditions] = conditions.map { $0.dictionaryRepresentation }
        return dictionary
    }
}
