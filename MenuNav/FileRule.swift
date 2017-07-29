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
        case files(name: String?, ext: String?)
        case folders(name: String)
    }
    
    enum Filter: Int {
        case include
        case exclude
    }
    
    // MARK: - Properties
    
    var target: Target
    var filter: Filter
    
    // MARK: - Init
    
    init() {
        
        self.target = .files(name: nil, ext: nil)
        self.filter = .include
    }
    
    init(target: Target, filter: Filter) {
    
        self.target = target
        self.filter = filter
    }
    
    // MARK: - Matching
    
    func includes(directory: Directory) -> Bool {
    
        switch filter {
        case .include:
            return matches(directory: directory)
        case .exclude:
            return false
        }
    }
    
    func includes(file: File) -> Bool {
        
        switch filter {
        case .include:
            return matches(file: file)
        case .exclude:
            return false
        }
    }
    
    func excludes(directory: Directory) -> Bool {
        
        switch filter {
        case .include:
            return false
        case .exclude:
            return matches(directory: directory)
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
    
    // MARK: - Matching
    
    private func matches(directory: Directory) -> Bool {
        
        switch target {
        case .files(_,_):
            return false
        case .folders(name: let name):
            return name == directory.name
        }
    }
    
    private func matches(file: File) -> Bool {
        
        switch target {
        
        // Match file name and extension
        case let .files(.some(name), .some(ext)):
            return name == file.name && ext == file.ext
            
        // Match file name only
        case let .files(.some(name), .none):
            return name == file.name
            
        // Match extension only
        case let .files(.none, .some(ext)):
            return ext == file.ext
            
        // Match folders
        case .folders(_):
            return false
            
        // Default (This shouldn't be called)
        default:
            return false
        }
    }
    
    // MARK: - Display Name
    
    var itemName: String? {
        
        switch target {
        case let .files(name, _):
            return name
        case let .folders(name):
            return name
        }
    }
    
    var itemExtension: String? {
        
        switch target {
        case let .files(_, ext):
            return ext
        case .folders(_):
            return nil
        }
    }
    
    var displayName: String {
        return "Rule Display Name"
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
        static let targetType = "TargetType"
        static let targetTypeFiles = "TargetTypeFile"
        static let targetTypeFolders = "TargetTypeFolder"
        static let targetName = "TargetName"
        static let targetExtension = "TargetExtension"
    }

    init?(dictionaryRepresentation dictionary: Dictionary<String, Any>) {
        
        guard let type = dictionary[Keys.targetType] as? String else {
            return nil
        }
        
        let name = dictionary[Keys.targetName] as? String
        let ext = dictionary[Keys.targetExtension] as? String
        
        switch type {
        case Keys.targetTypeFolders:
            
            guard let folderName = name else {
                return nil
            }
            
            self = .folders(name: folderName)
            
        case Keys.targetTypeFiles:
            
            if name == nil && ext == nil {
                return nil
            }
            
            self = .files(name: name, ext: ext)
        
        default:
            return nil
        }
    }
    
    var dictionaryRepresentation: Dictionary<String, Any> {
        
        var dictionary = Dictionary<String, Any>()
        
        switch self {
        case let .files(name, ext):
            dictionary[Keys.targetType] = Keys.targetTypeFiles
            dictionary[Keys.targetName] = name
            dictionary[Keys.targetExtension] = ext
        case let .folders(name):
            dictionary[Keys.targetType] = Keys.targetTypeFolders
            dictionary[Keys.targetName] = name
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
