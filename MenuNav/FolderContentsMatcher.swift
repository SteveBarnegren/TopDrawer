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
    case filesWithFullName(String)
    case foldersWithName(String)
    
    func matches(directory: Directory) -> Bool {
        
        switch self {
        case let .filesWithExtension(ext):
            
            return directory.extendedAttributes!.containsFiles(withExtension: ext)
            
            /*
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
  */
            
        case let .filesWithFullName(name):
            return directory.extendedAttributes!.containsFiles(withFullName: name)
            //return directory.extendedAttributes!.containedFileNames.contains{ $0 == name }
        case let .foldersWithName(name):
            return directory.extendedAttributes!.containsFolders(withName: name)
           // return directory.extendedAttributes!.containedFolderNames.contains{ $0 == name }
        }
    }
    
    static func == (lhs: FolderContentsMatcher, rhs: FolderContentsMatcher) -> Bool {
        
        switch (lhs, rhs) {
        case let (.filesWithExtension(e1), .filesWithExtension(e2)):
            return e1 == e2
        case let (.filesWithFullName(n1), .filesWithFullName(n2)):
            return n1 == n2
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
            static let FilesWithFullName = "FilesWithFullName"
            static let FoldersWithName = "FoldersWithName"
        }
        static let Name = "Name"
        static let Extension = "Extension"
    }
    
    init?(dictionaryRepresentation dictionary: [String: Any]) {
        
        guard let caseType = dictionary[Keys.CaseKey] as? String else {
            return nil
        }
        
        var result: FolderContentsMatcher?
        
        switch caseType {
        case Keys.Case.FilesWithExtension:
            
            if let ext = dictionary[Keys.Extension] as? String {
                result = .filesWithExtension(ext)
            }
            
        case Keys.Case.FilesWithFullName:
            
            if let name = dictionary[Keys.Name] as? String {
                result = .filesWithFullName(name)
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
        } else {
            return nil
        }
    }
    
    var dictionaryRepresentation: [String: Any] {
        
    var dictionary = [String: Any]()
        
        switch self {
        case let .filesWithExtension(ext):
            dictionary[Keys.CaseKey] = Keys.Case.FilesWithExtension
            dictionary[Keys.Extension] = ext
        case let .filesWithFullName(name):
            dictionary[Keys.CaseKey] = Keys.Case.FilesWithFullName
            dictionary[Keys.Name] = name
        case let .foldersWithName(name):
            dictionary[Keys.CaseKey] = Keys.Case.FoldersWithName
            dictionary[Keys.Name] = name
        }
        
        return dictionary
    }
}
