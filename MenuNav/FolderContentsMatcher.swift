//
//  FolderContentsMatcher.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

enum FolderContentsMatcher {
    case filesWithExtension(String)
    case filesWithNameAndExtension(name: String, ext: String)
    case foldersWithName(String)
    
    func matches(directory: Directory) -> Bool {
        
        switch self {
        case let .filesWithExtension(ext):
            
            guard let extendedAttributes = directory.extendedAttributes else {
                return false
            }
            
            for fileName in extendedAttributes.containedFileNames {
                let components = fileName.components(separatedBy: ".")
                
                if components.count < 2 {
                    continue
                }
                
                if components.last! == ext {
                    return true
                }
            }
            
            return false
            
        case let .filesWithNameAndExtension(name, ext):
            
            let extendedAttributes = directory.extendedAttributes!
            
            for fileName in extendedAttributes.containedFileNames {
                let components = fileName.components(separatedBy: ".")
                
                if components.count != 2 {
                    continue
                }
                
                if components[0] == name && components[1] == ext {
                    return true
                }
            }
            
            return false
            
        case let .foldersWithName(name):
            return directory.extendedAttributes!.containedFolderNames.contains{ $0 == name }
        }
    }
    
    static func ==(lhs: FolderContentsMatcher, rhs: FolderContentsMatcher) -> Bool {
        
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

// MARK: - DictionaryRepresentable

extension FolderContentsMatcher: DictionaryRepresentable {
    
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
        
        var result: FolderContentsMatcher?
        
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
