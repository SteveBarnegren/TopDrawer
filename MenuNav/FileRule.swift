//
//  FileType.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/05/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

struct FileRule: Rule {
    
    // MARK: - Properties
    
    static var storageKey = "File Rules"
    
    let conditions: [FileCondition]
    
    var numberOfConditions: Int {
        return conditions.count
    }
    
    // MARK: - Init
    
    init(conditions: [Condition]) {
        self.conditions = conditions
    }
    
    // MARK: - Matching
    
    func includes(file: File) -> Bool {
        
        for condition in conditions {
            if !condition.matches(file: file) {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Decision Tree
    
    static func makeDecisionTree() -> DecisionNode<FileCondition> {
        return fileConditionDecisionTree()
    }
}

// MARK: - DictionaryRepresentable
extension FileRule: DictionaryRepresentable {
    
    struct Keys {
        static let Conditions = "Conditions"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard let conditionsArray = dictionary[Keys.Conditions] as? Array<Dictionary<String, Any>> else {
            return nil
        }

        let conditions = conditionsArray.flatMap{ Condition(dictionaryRepresentation: $0) }
        self.init(conditions: conditions)
    }
    
    var dictionaryRepresentation: Dictionary<String, Any> {
     
        var dictionary = Dictionary<String, Any>()
        let conditionsArray = conditions.map{ $0.dictionaryRepresentation }
        dictionary[Keys.Conditions] = conditionsArray
        return dictionary
    }
}

