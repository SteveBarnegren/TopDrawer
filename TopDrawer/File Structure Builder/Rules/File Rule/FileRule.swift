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
    
    init(conditions: [FileCondition]) {

        if conditions.count == 0 {
            fatalError("FileRule must have at least one condition")
        }
        
        self.conditions = conditions.sorted(by: { $0.perfomanceValue < $1.perfomanceValue })
    }
    
    // MARK: - Matching
    
    func includes(file: File, inHierarchy hierarchy: HierarchyInformation) -> Bool {
        
        for condition in conditions {
            if !condition.matches(file: file, inHierarchy: hierarchy) {
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

// MARK: - Equatable

extension FileRule: Equatable {
    
    static func == (lhs: FileRule, rhs: FileRule) -> Bool {
        return lhs.conditions == rhs.conditions
    }
}

// MARK: - DictionaryRepresentable
extension FileRule: DictionaryRepresentable {
    
    struct Keys {
        static let Conditions = "Conditions"
    }
    
    init?(dictionaryRepresentation dictionary: [String: Any]) {
        
        guard let conditionsArray = dictionary[Keys.Conditions] as? [[String: Any]] else {
            return nil
        }
        
        guard conditionsArray.count > 0 else {
            return nil
        }

        let conditions = conditionsArray.flatMap { Condition(dictionaryRepresentation: $0) }
        self.init(conditions: conditions)
    }
    
    var dictionaryRepresentation: [String: Any] {
     
        var dictionary = [String: Any]()
        let conditionsArray = conditions.map { $0.dictionaryRepresentation }
        dictionary[Keys.Conditions] = conditionsArray
        return dictionary
    }
}
