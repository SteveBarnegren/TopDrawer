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
    case contains(String)
    
    func matches(string: String) -> Bool {
        
        switch self {
        case let .matching(stringToMatch):
            return string == stringToMatch
        case let .contains(stringToMatch):
            return string.contains(stringToMatch)
        }
    }
}

public struct FolderRule {
    
    // MARK: - Contents Matcher
    
    enum ContentsMatcher {
        case filesWithExtension(String)
        case filesWithNameAndExtension(name: String, ext: String)
        
        func matches(directory: Directory) -> Bool {
            
            switch self {
            case let .filesWithExtension(ext):
                return directory.contents.flatMap{ $0 as? File }.contains{ $0.ext == ext }
            case let .filesWithNameAndExtension(name, ext):
                return directory.contents.flatMap{ $0 as? File }.contains{ $0.name == name && $0.ext == ext }
            }
        }
    }
    
    // MARK: - Condition
    
    enum Condition {
        case path(String)
        case name(StringMatcher)
        case contains(ContentsMatcher)
        
        func matches(directory: Directory) -> Bool {
            
            switch self {
            case let .path(path):
                return directory.path == path
            case let .name(stringMatcher):
                return stringMatcher.matches(string: directory.name)
            case let .contains(contentsMatcher):
                return contentsMatcher.matches(directory: directory)
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
