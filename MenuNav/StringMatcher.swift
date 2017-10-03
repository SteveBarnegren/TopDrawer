//
//  StringMatcher.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

enum StringMatcher {
    case matching(String)
    case notMatching(String)
    case containing(String)
    case notContaining(String)
    
    var string: String {
        switch self {
        case .matching(let string): return string
        case .notMatching(let string): return string
        case .containing(let string): return string
        case .notContaining(let string): return string
        }
    }
    
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
    
    static func == (lhs: StringMatcher, rhs: StringMatcher) -> Bool {
        
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

// MARK: - DictionaryRepresentable

// swiftlint:disable identifier_name
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
    
    init?(dictionaryRepresentation dictionary: [String: Any]) {
        
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
        } else {
            return nil
        }
    }
    
    var dictionaryRepresentation: [String: Any] {
        
        var dictionary = [String: Any]()
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
