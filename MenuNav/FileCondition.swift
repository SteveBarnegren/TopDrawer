//
//  FileCondition.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

enum FileCondition {
    case name(StringMatcher)
    case ext(StringMatcher)
    case fullName(StringMatcher)
    case parentContains(FolderContentsMatcher)
    case parentDoesntContain(FolderContentsMatcher)

    func matches(file: File) -> Bool {
        
        switch self {
        case let .name(stringMatcher):
            return stringMatcher.matches(string: file.name)
        case let .ext(stringMatcher):
            return stringMatcher.matches(string: file.ext)
        case let .fullName(stringMatcher):
            return stringMatcher.matches(string: file.fullName)
        case let .parentContains(contentsMatcher):
            guard let parent = file.parent else { return false }
            return contentsMatcher.matches(directory: parent)
        case let .parentDoesntContain(contentsMatcher):
            guard let parent = file.parent else { return false }
            return !contentsMatcher.matches(directory: parent)
        }
    }
    
    var perfomanceValue: Int {
        
        switch self {
        case .fullName: return 0
        case .name: return 1
        case .ext: return 2
        case .parentContains: return 3
        case .parentDoesntContain: return 4
        }
    }
}

// MARK: - ConditionProtocol

extension FileCondition: CondtionProtocol {
    var displayDiscription: String {
        
        switch self {
        case let .name(stringMatcher):
            return "Name " + makeString(fromStringMatcher: stringMatcher)
        case let .ext(stringMatcher):
            return "Extension " + makeString(fromStringMatcher: stringMatcher)
        case let .fullName(stringMatcher):
            return "Full name " + makeString(fromStringMatcher: stringMatcher)
        case let .parentContains(contentsMatcher):
            return "Parent folder contains " + makeString(fromContentsMatcher: contentsMatcher)
        case let .parentDoesntContain(contentsMatcher):
            return "Parent folder doesn't contain " + makeString(fromContentsMatcher: contentsMatcher)
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
        case let .filesWithExtension(string):
            return "files with extension \(string)"
        case let .filesWithFullName(string):
            return "file with full name \(string)"
        case let .foldersWithName(string):
            return "folder with name \(string)"
        }
    }
}

// MARK: - Equatable

extension FileCondition: Equatable {
    
    static func == (lhs: FileCondition, rhs: FileCondition) -> Bool {
        switch (lhs, rhs) {
        case let (.name(sm1), .name(sm2)):
            return sm1 == sm2
        case let (.ext(sm1), .ext(sm2)):
            return sm1 == sm2
        case let (.fullName(sm1), .fullName(sm2)):
            return sm1 == sm2
        case let (.parentContains(cm1), .parentContains(cm2)):
            return cm1 == cm2
        case let (.parentDoesntContain(cm1), .parentDoesntContain(cm2)):
            return cm1 == cm2
        default:
            return false
        }
    }
}

// MARK: - DecisionTreeElement

extension FileCondition: DecisionTreeElement {
    
    func decisionTreeInput() -> String {
        
        switch self {
        case let .name(stringMatcher):
            return stringMatcher.inputString
        case let .ext(stringMatcher):
            return stringMatcher.inputString
        case let .fullName(stringMatcher):
            return stringMatcher.inputString
        case let .parentContains(contentsMatcher):
            return contentsMatcher.inputString
        case let .parentDoesntContain(contentsMatcher):
            return contentsMatcher.inputString
        }
    }
}

// MARK: - DictionaryRepresentable

extension FileCondition: DictionaryRepresentable {
    
    struct Keys {
        static let CaseKey = "Case"
        struct Case {
            static let Name = "Name"
            static let Ext = "Ext"
            static let FullName = "FullName"
            static let ParentContains = "ParentContains"
            static let ParentDoesntContain = "ParentDoesntContain"
        }
        static let AssociatedValue = "AssociatedValue"
    }
    
    init?(dictionaryRepresentation dictionary: [String: Any]) {
        
        guard let caseType = dictionary[Keys.CaseKey] as? String else {
            return nil
        }
        
        var result: FileCondition?
        
        switch caseType {
        case Keys.Case.Name:
            
            if let stringMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDictionary) {
                result = .name(stringMatcher)
            }
            
        case Keys.Case.Ext:
            
            if let stringMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDictionary) {
                result = .ext(stringMatcher)
            }
            
        case Keys.Case.FullName:
            
            if let stringMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let stringMatcher = StringMatcher(dictionaryRepresentation: stringMatcherDictionary) {
                result = .fullName(stringMatcher)
            }
            
        case Keys.Case.ParentContains:
            
            if let contentsMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let contentsMatcher = FolderContentsMatcher(dictionaryRepresentation: contentsMatcherDictionary) {
                result = .parentContains(contentsMatcher)
            }
            
        case Keys.Case.ParentDoesntContain:
            
            if let contentsMatcherDictionary = dictionary[Keys.AssociatedValue] as? [String: Any],
                let contentsMatcher = FolderContentsMatcher(dictionaryRepresentation: contentsMatcherDictionary) {
                result = .parentDoesntContain(contentsMatcher)
            }

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
        case let .name(stringMatcher):
            dictionary[Keys.CaseKey] = Keys.Case.Name
            dictionary[Keys.AssociatedValue] = stringMatcher.dictionaryRepresentation
            
        case let .ext(stringMatcher):
            dictionary[Keys.CaseKey] = Keys.Case.Ext
            dictionary[Keys.AssociatedValue] = stringMatcher.dictionaryRepresentation
            
        case let .fullName(stringMatcher):
            dictionary[Keys.CaseKey] = Keys.Case.FullName
            dictionary[Keys.AssociatedValue] = stringMatcher.dictionaryRepresentation
        
        case let .parentContains(contentsMatcher):
            dictionary[Keys.CaseKey] = Keys.Case.ParentContains
            dictionary[Keys.AssociatedValue] = contentsMatcher.dictionaryRepresentation
            
        case let .parentDoesntContain(contentsMatcher):
            dictionary[Keys.CaseKey] = Keys.Case.ParentDoesntContain
            dictionary[Keys.AssociatedValue] = contentsMatcher.dictionaryRepresentation
        }
        
        return dictionary
    }
}
