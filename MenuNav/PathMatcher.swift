//
//  PathMatcher.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

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
    
    static func == (lhs: PathMatcher, rhs: PathMatcher) -> Bool {
        
        switch (lhs, rhs) {
        case let (.matching(s1), .matching(s2)):
            return s1 == s2
        case let (.notMatching(s1), .notMatching(s2)):
            return s1 == s2
        case (.notMatching, .matching): fallthrough
        case (.matching, .notMatching):
            return false
        }
    }
}

// MARK: - Decision Tree Input

extension PathMatcher {
    
    var inputString: String {
        
        switch self {
        case let .matching(s):
            return s
        case let .notMatching(s):
            return s
        }
    }
}

// MARK: - DictionaryRepresentable

extension PathMatcher: DictionaryRepresentable {
    
    struct Keys {
        static let CaseKey = "Case Key"
        struct Case {
            static let Matching = "Matching"
            static let NotMatching = "Not Matching"
        }
        static let Value = "Value"
    }
    
    init?(dictionaryRepresentation dictionary: [String: Any]) {
        
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
        } else {
            return nil
        }
    }
    
    var dictionaryRepresentation: [String: Any] {
        
        var dictionary = [String: Any]()
        
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
