//
//  FileType.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/05/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

public struct FileRule {
    
    // MARK: - Types
    
    enum Target {
        case matchingName(String)
        case matchingExtension(String)
        case matchingNameAndExtension(name: String, ext: String)
    }
    
    enum Filter: Int {
        case include
        case exclude
    }
    
    // MARK: - Properties
    
    var target: Target
    var filter: Filter
    
    // MARK: - Init
    
    init(target: Target, filter: Filter) {
    
        self.target = target
        self.filter = filter
    }
    
    // MARK: - Matching
    
    func includes(file: File) -> Bool {
        
        switch filter {
        case .include:
            return matches(file: file)
        case .exclude:
            return false
        }
    }
    
    func excludes(file: File) -> Bool {
        
        switch filter {
        case .include:
            return false
        case .exclude:
            return matches(file: file)
        }
    }
    
    private func matches(file: File) -> Bool {
        
        switch target {
        
        // Match file name and extension
        case let .matchingNameAndExtension(name, ext):
            return name == file.name && ext == file.ext
            
        // Match file name only
        case let .matchingName(name):
            return name == file.name
            
        // Match extension only
        case let .matchingExtension(ext):
            return ext == file.ext
        }
    }
    
    // MARK: - Display Name
    
    var itemName: String? {
        
        switch target {
        case let .matchingName(name):
            return name
        case .matchingExtension(_):
            return nil
        case let .matchingNameAndExtension(name, _):
            return name
        }
    }
    
    var itemExtension: String? {
        
        switch target {
        case .matchingName(_):
            return nil
        case let .matchingExtension(ext):
            return ext
        case let .matchingNameAndExtension(_, ext):
            return ext
        }
    }
}

// MARK: - Equatable

extension FileRule.Target: Equatable {
    public static func ==(lhs: FileRule.Target, rhs: FileRule.Target) -> Bool {
        
        switch (lhs, rhs) {
        case let (.matchingName(n1), .matchingName(n2)):
            return n1 == n2
        case let (.matchingExtension(e1), .matchingExtension(e2)):
            return e1 == e2
        case let (.matchingNameAndExtension(n1, e1), .matchingNameAndExtension(n2, e2)):
            return n1 == n2 && e1 == e2
        default:
            return false
        }
    }
}

extension FileRule: Equatable {
    public static func ==(lhs: FileRule, rhs: FileRule) -> Bool {
        
        return( lhs.filter == rhs.filter &&
            lhs.target == rhs.target )
    }
}

// MARK: - DictionaryRepresentable

extension FileRule.Filter: StringRepresentable {
    
    private struct StringValues {
        static let include = "Include"
        static let exclude = "Exclude"
    }
    
    init?(stringRepresentation: String) {
        
        switch stringRepresentation {
        case StringValues.include:
            self = .include
        case StringValues.exclude:
            self = .exclude
        default:
            return nil
        }
    }
    
    var stringRepresentation: String {
        
        switch self {
        case .include:
            return StringValues.include
        case .exclude:
            return StringValues.exclude
        }
    }
}

extension FileRule.Target: DictionaryRepresentable {
    
    private struct Keys {
        static let TargetType = "TargetType"
        struct TargetTypes {
            static let MatchingName = "MatchingName"
            static let MatchingExtension = "MatchingExtension"
            static let MatchingNameAndExtension = "MatchingNameAndExtension"
        }
        static let TargetName = "TargetName"
        static let TargetExtension = "TargetExtension"
    }

    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard let type = dictionary[Keys.TargetType] as? String else {
            return nil
        }
        
        let name = dictionary[Keys.TargetName] as? String
        let ext = dictionary[Keys.TargetExtension] as? String
        
        var result: FileRule.Target?
        
        switch type {
        case Keys.TargetTypes.MatchingName:
            
            if let name = name {
                result = .matchingName(name)
            }
            
        case Keys.TargetTypes.MatchingExtension:
            
            if let ext = ext {
                result = .matchingExtension(ext)
            }
           
        case Keys.TargetTypes.MatchingNameAndExtension:
            
            if let name = name, let ext = ext {
                result = .matchingNameAndExtension(name: name, ext: ext)
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
        case let .matchingName(name):
            dictionary[Keys.TargetType] = Keys.TargetTypes.MatchingName
            dictionary[Keys.TargetName] = name
        case let .matchingExtension(ext):
            dictionary[Keys.TargetType] = Keys.TargetTypes.MatchingExtension
            dictionary[Keys.TargetExtension] = ext
        case let .matchingNameAndExtension(name, ext):
            dictionary[Keys.TargetType] = Keys.TargetTypes.MatchingNameAndExtension
            dictionary[Keys.TargetName] = name
            dictionary[Keys.TargetExtension] = ext
        }
    
        return dictionary
    }
}

extension FileRule: DictionaryRepresentable {
    
    struct Keys {
        static let filter = "Filter"
        static let target = "Target"
    }
    
    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard
            let targetDict = dictionary[Keys.target] as? Dictionary<String, Any>,
            let target = Target(dictionaryRepresentation: targetDict)
            else {
                print("Unable to create file rule target from dictionary: \(dictionary)")
                return nil
        }
        
        guard
            let filterString = dictionary[Keys.filter] as? String,
            let filter = Filter(stringRepresentation: filterString)
            else {
                print("File rule unable to create file rule filter from dictionary: \(dictionary)")
                return nil
        }
        
        self.init(target: target, filter: filter)
    }
    
    var dictionaryRepresentation: Dictionary<String, Any> {
        
        var dictionary = Dictionary<String, Any>()
        
        dictionary[Keys.filter] = filter.stringRepresentation
        dictionary[Keys.target] = target.dictionaryRepresentation
        
        return dictionary
    }
}
