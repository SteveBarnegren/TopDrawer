//
//  HierarchyMatcher.swift
//  MenuNav
//
//  Created by Steve Barnegren on 21/10/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

enum HierarcyMatcher {
    case folderWithName(StringMatcher)
    
    func matches(hierarchy: HierarchyInformation) -> Bool {
        
        switch self {
        case let .folderWithName(stringMatcher):
            return hierarchy.containsFolder { stringMatcher.matches(string: $0) }
        }
    }
    
    var inputString: String {
        
        switch self {
        case let .folderWithName(stringMatcher):
            return stringMatcher.inputString
        }
    }
    
}

// MARK: - Equatable
extension HierarcyMatcher: Equatable {
    public static func == (lhs: HierarcyMatcher, rhs: HierarcyMatcher) -> Bool {
        
        switch (lhs, rhs) {
        case let (.folderWithName(sm1), .folderWithName(sm2)):
            return sm1 == sm2
        }
    }
}

// MARK: - Dictionary Representable
extension HierarcyMatcher: DictionaryRepresentable {
    
    struct Keys {
        static let type = "Type"
        static let type_FolderWithName = "FolderWithName"
        static let stringMatcher = "StringMatcher"
    }
    
    init?(dictionaryRepresentation: [String: Any]) {
        
        guard let typeString = dictionaryRepresentation[Keys.type] as? String else {
            return nil
        }
        
        switch typeString {
        case Keys.type_FolderWithName:
            
            guard let stringMatcherDict = dictionaryRepresentation[Keys.stringMatcher] as? [String: Any] else {
                return nil
            }
            
            guard let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDict) else {
                return nil
            }
            
            self = .folderWithName(stringMatcher)
        default:
            return nil
        }
       
    }
    
    var dictionaryRepresentation: [String: Any] {
        
        var dictionary = [String: Any]()
        
        switch self {
        case .folderWithName(let stringMatcher):
            dictionary[Keys.type] = Keys.type_FolderWithName
            dictionary[Keys.stringMatcher] = stringMatcher.dictionaryRepresentation
        }
        
        return dictionary
    }
}
