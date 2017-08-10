//
//  FolderRule.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - String Matcher

enum StringMatcher {
    case matching(String)
    case notMatching(String)
    case containing(String)
    case notContaining(String)
    
    func matches(string: String) -> Bool {
        
        switch self {
        case let .matching(stringToMatch):
            return string == stringToMatch
        case let .notMatching(stringToMatch):
            return !(string == stringToMatch)
        case let .containing(stringToMatch):
            return string.contains(stringToMatch)
        case let .notContaining(stringToMatch):
            return !string.contains(stringToMatch)
        }
    }
    
    static func ==(lhs: StringMatcher, rhs: StringMatcher) -> Bool {
        
        switch (lhs, rhs) {
        case let (.matching(s1), .matching(s2)):
            return s1 == s2
        case let (.notMatching(s1), .notMatching(s2)):
            return s1 == s2
        case let (.containing(s1), .containing(s2)):
            return s1 == s2
        case let (.notContaining(s1), .notContaining(s2)):
            return s1 == s2
        default:
            return false
        }
    }
}

enum PathMatcher {
    case matching(String)
    case notMatching(String)
    
    func matches(string: String) -> Bool {
        
        switch self {
        case let .matching(stringToMatch):
            return string == stringToMatch
        case let .notMatching(stringToMatch):
            return !(string == stringToMatch)
        }
    }
    
    static func ==(lhs: PathMatcher, rhs: PathMatcher) -> Bool {
        
        switch (lhs, rhs) {
        case let (.matching(s1), .matching(s2)):
            return s1 == s2
        case let (.notMatching(s1), .notMatching(s2)):
            return s1 == s2
        default:
            return false
        }
    }
}

public struct FolderRule {
    
    // MARK: - Contents Matcher
    
    enum ContentsMatcher {
        case filesWithExtension(String)
        case filesWithNameAndExtension(name: String, ext: String)
        case foldersWithName(String)
        
        func matches(directory: Directory) -> Bool {
            
            switch self {
            case let .filesWithExtension(ext):
                return directory.contents.flatMap{ $0 as? File }.contains{ $0.ext == ext }
            case let .filesWithNameAndExtension(name, ext):
                return directory.contents.flatMap{ $0 as? File }.contains{ $0.name == name && $0.ext == ext }
            case let .foldersWithName(name):
                return directory.contents.flatMap{ $0 as? Directory }.contains{ $0.name == name }
            }
        }
        
        static func ==(lhs: ContentsMatcher, rhs: ContentsMatcher) -> Bool {
            
            switch (lhs, rhs) {
            case let (.filesWithExtension(e1), .filesWithExtension(e2)):
                return e1 == e2
            case let (.filesWithNameAndExtension(n1, e1), .filesWithNameAndExtension(n2, e2)):
                return n1 == n2 && e1 == e2
            case let (.foldersWithName(n1), .foldersWithName(n2)):
                return n1 == n2
            default:
                return false
            }
        }
    }
    
    // MARK: - Condition
    
    enum Condition {
        case path(PathMatcher)
        case name(StringMatcher)
        case contains(ContentsMatcher)
        case doesntContain(ContentsMatcher)
        
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

// MARK: - FolderRule: Dictionary Representable

extension StringMatcher: DictionaryRepresentable {
    
    struct Keys {
        struct Case {
            static let _key = "Key"
            static let Matching = "Matching"
            static let NotMatching = "Not Matching"
            static let Containing = "Containing"
            static let NotContaining = "Not Containing"
        }
        static let Value = "Value"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard
            let caseType = dictionary[Keys.Case._key] as? String,
            let value = dictionary[Keys.Value] as? String
        else {
            return nil
        }
        
        var result: StringMatcher?

        switch caseType {
        case Keys.Case.Matching:
            result = .matching(value)
        case Keys.Case.NotMatching:
            result = .notMatching(value)
        case Keys.Case.Containing:
            result = .containing(value)
        case Keys.Case.NotContaining:
            result = .notContaining(value)
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
        case let .matching(string):
            dictionary[Keys.Case._key] = Keys.Case.Matching
            dictionary[Keys.Value] = string
        case let .notMatching(string):
            dictionary[Keys.Case._key] = Keys.Case.NotMatching
            dictionary[Keys.Value] = string
        case let .containing(string):
            dictionary[Keys.Case._key] = Keys.Case.Containing
            dictionary[Keys.Value] = string
        case let .notContaining(string):
            dictionary[Keys.Case._key] = Keys.Case.NotContaining
            dictionary[Keys.Value] = string
        }
        
        return dictionary
    }
}

extension PathMatcher: DictionaryRepresentable {
    
    struct Keys {
        static let CaseKey = "Case Key"
        struct Case {
            static let Matching = "Matching"
            static let NotMatching = "Not Matching"
        }
        static let Value = "Value"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard
            let caseType = dictionary[Keys.CaseKey] as? String,
            let value = dictionary[Keys.Value] as? String else {
                return nil
        }
        
        var result: PathMatcher?
        
        switch caseType {
        case Keys.Case.Matching:
            result = .matching(value)
        case Keys.Case.NotMatching:
            result = .notMatching(value)
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
        case let .matching(string):
            dictionary[Keys.CaseKey] = Keys.Case.Matching
            dictionary[Keys.Value] = string
        case let .notMatching(string):
            dictionary[Keys.CaseKey] = Keys.Case.NotMatching
            dictionary[Keys.Value] = string
        }
        
        return dictionary
    }

}

extension FolderRule.ContentsMatcher: DictionaryRepresentable {
    
    struct Keys {
        static let CaseKey = "CaseKey"
        struct Case {
            static let FilesWithExtension = "FilesWithExtension"
            static let FilesWithNameAndExtension = "FilesWithNameAndExtension"
            static let FoldersWithName = "FoldersWithName"
        }
        static let Name = "Name"
        static let Extension = "Extension"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard let caseType = dictionary[Keys.CaseKey] as? String else {
            return nil
        }
        
        var result: FolderRule.ContentsMatcher?
        
        switch caseType {
        case Keys.Case.FilesWithExtension:
            
            if let ext = dictionary[Keys.Extension] as? String {
                result = .filesWithExtension(ext)
            }
            
        case Keys.Case.FilesWithNameAndExtension:
            
            if let name = dictionary[Keys.Name] as? String,
                let ext = dictionary[Keys.Extension] as? String {
                result = .filesWithNameAndExtension(name: name, ext: ext)
            }
            
        case Keys.Case.FoldersWithName:
            
            if let name = dictionary[Keys.Name] as? String {
                result = .foldersWithName(name)
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
        case let .filesWithExtension(ext):
            dictionary[Keys.CaseKey] = Keys.Case.FilesWithExtension
            dictionary[Keys.Extension] = ext
        case let .filesWithNameAndExtension(name, ext):
            dictionary[Keys.CaseKey] = Keys.Case.FilesWithNameAndExtension
            dictionary[Keys.Name] = name
            dictionary[Keys.Extension] = ext
        case let .foldersWithName(name):
            dictionary[Keys.CaseKey] = Keys.Case.FoldersWithName
            dictionary[Keys.Name] = name
        }
        
        return dictionary
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
                let contentsMatcher = FolderRule.ContentsMatcher(dictionaryRepresentation: contentsMatcherDictionary) {
                result = .contains(contentsMatcher)
            }
            
        case Keys.Case.DoesntContain:
            
            if let contentsMatcherDictionary = dictionary[Keys.AssociatedValue] as? Dictionary<String, Any>,
                let contentsMatcher = FolderRule.ContentsMatcher(dictionaryRepresentation: contentsMatcherDictionary) {
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
