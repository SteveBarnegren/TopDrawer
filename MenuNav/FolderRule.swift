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
    
    // MARK: - Condition
    
    enum Condition {
        case path(PathMatcher)
        case name(StringMatcher)
        case contains(FolderContentsMatcher)
        case doesntContain(FolderContentsMatcher)
        
        func matches(directory: Directory) -> Bool {
            
            switch self {
            case let .path(pathMatcher):
                return pathMatcher.matches(string: directory.path)
            case let .name(stringMatcher):
                return stringMatcher.matches(string: directory.name)
            case let .contains(contentsMatcher):
                return contentsMatcher.matches(directory: directory)
            case let .doesntContain(contentsMatcher):
                return !contentsMatcher.matches(directory: directory)
            }
        }
        
        static func ==(lhs: Condition, rhs: Condition) -> Bool {
            switch (lhs, rhs) {
            case let (.path(pathMatcher1), .path(pathMatcher2)):
                return pathMatcher1 == pathMatcher2
            case let (.name(stringMatcher1), .name(stringMatcher2)):
                return stringMatcher1 == stringMatcher2
            case let (.contains(contentsMatcher1), .contains(contentsMatcher2)):
                return contentsMatcher1 == contentsMatcher2
            case let (.doesntContain(contentsMatcher1), .doesntContain(contentsMatcher2)):
                return contentsMatcher1 == contentsMatcher2
            default:
                return false
            }
        }
    }
    
    // MARK: - MatchType
    
    enum MatchType {
        case any
        case all
    }
    
    // MARK: - Properties
    
    let conditions: [Condition]
    let matchType: MatchType
    
    var numberOfConditions: Int {
        return conditions.count
    }
    
    // MARK: - Init
    
    init(conditions: [Condition], matchType: MatchType) {
        self.conditions = conditions
        self.matchType = matchType
    }
    
    // MARK: - Matching
    
    func excludes(directory: Directory) -> Bool {
        
        switch matchType {
        case .any:
            
            for condition in conditions {
                if condition.matches(directory: directory) {
                    return true
                }
            }
            return false
            
        case .all:
            
            for condition in conditions {
                if !condition.matches(directory: directory) {
                    return false
                }
            }
            return true
        }
    }
}



extension FolderRule.Condition: DictionaryRepresentable {
    
    struct Keys {
        static let CaseKey = "CaseKey"
        struct Case {
            static let Path = "Path"
            static let Name = "Name"
            static let Contains = "Contains"
            static let DoesntContain = "DoesntContain"
        }
        static let AssociatedValue = "AssociatedValue"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard let caseType = dictionary[Keys.CaseKey] as? String else {
            return nil
        }
        
        var result: FolderRule.Condition?
        
        switch caseType {
        case Keys.Case.Path:
            
            if let pathMatcherDictionary = dictionary[Keys.AssociatedValue] as? Dictionary<String, Any>,
                let pathMatcher = PathMatcher(dictionaryRepresentation: pathMatcherDictionary) {
                result = .path(pathMatcher)
            }
            
        case Keys.Case.Name:
            
            if let stringMatcherDictionary = dictionary[Keys.AssociatedValue] as? Dictionary<String, Any>,
                let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDictionary) {
                result = .name(stringMatcher)
            }
            
        case Keys.Case.Contains:
            
            if let contentsMatcherDictionary = dictionary[Keys.AssociatedValue] as? Dictionary<String, Any>,
                let contentsMatcher = FolderContentsMatcher(dictionaryRepresentation: contentsMatcherDictionary) {
                result = .contains(contentsMatcher)
            }
            
        case Keys.Case.DoesntContain:
            
            if let contentsMatcherDictionary = dictionary[Keys.AssociatedValue] as? Dictionary<String, Any>,
                let contentsMatcher = FolderContentsMatcher(dictionaryRepresentation: contentsMatcherDictionary) {
                result = .doesntContain(contentsMatcher)
            }
        
        default:
            break
        }
        
        if let result = result {
            self = result
        }
        else{
            return nil
        }
    }
    
    var dictionaryRepresentation: Dictionary<String, Any> {
        
        var dictionary = Dictionary<String, Any>()
        
        switch self {
        case let .path(pathMatcher):
            
            dictionary[Keys.CaseKey] = Keys.Case.Path
            dictionary[Keys.AssociatedValue] = pathMatcher.dictionaryRepresentation
            
        case let .name(stringMatcher):
            
            dictionary[Keys.CaseKey] = Keys.Case.Name
            dictionary[Keys.AssociatedValue] = stringMatcher.dictionaryRepresentation
            
        case let .contains(contentsMatcher):
            
            dictionary[Keys.CaseKey] = Keys.Case.Contains
            dictionary[Keys.AssociatedValue] = contentsMatcher.dictionaryRepresentation
            
        case let .doesntContain(contentsMatcher):
            
            dictionary[Keys.CaseKey] = Keys.Case.DoesntContain
            dictionary[Keys.AssociatedValue] = contentsMatcher.dictionaryRepresentation
        }
        
        return dictionary
    }
    
}



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
        
        self.init(conditions: conditions, matchType: .all)
    }
    
    var dictionaryRepresentation: Dictionary<String, Any> {
        
        var dictionary = Dictionary<String, Any>()
        dictionary[Keys.Conditions] = conditions.map{ $0.dictionaryRepresentation }
        return dictionary
    }
}
