//
//  FolderConditionFormatter.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

class FolderConditionFormatter {
    
    func string(fromCondition condition: FolderRule.Condition) -> String {
        
        switch condition {
        case let .path(pathMatcher):
            return "Path " + makeString(fromPathMatcher: pathMatcher)
        case let .name(stringMatcher):
            return "Name " + makeString(fromStringMatcher: stringMatcher)
        case let .contains(contentsMatcher):
            return "Contains " + makeString(fromContentsMatcher: contentsMatcher)
        case let .doesntContain(contentsMatcher):
            return "Doesn't contain " + makeString(fromContentsMatcher: contentsMatcher)
        }
    }
    
    private func makeString(fromPathMatcher pathMatcher: PathMatcher) -> String {
        
        switch pathMatcher {
        case let .matching(string):
            return "is \(string)"
        case let .notMatching(string):
            return "is not \(string)"
        }
    }
    
    private func makeString(fromStringMatcher stringMatcher: StringMatcher) -> String {
        
        switch stringMatcher {
        case let .matching(string):
            return "is \(string)"
        case let .notMatching(string):
            return "is not \(string)"
        case let .containing(string):
            return "contains \(string)"
        case let .notContaining(string):
            return "doesn't contain \(string)"
        }
    }
    
    private func makeString(fromContentsMatcher contentsMatcher: FolderContentsMatcher) -> String {
        
        switch contentsMatcher {
        case let .filesWithExtension(ext):
            return "files with extension \(ext)"
        case let .filesWithFullName(name):
            return "file \(name)"
        case let .foldersWithName(name):
            return "folder with name \(name)"
        }
    }
}
