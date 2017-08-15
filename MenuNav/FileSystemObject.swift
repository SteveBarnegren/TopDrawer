//
//  FileSystemObject.swift
//  MenuNav
//
//  Created by Steve Barnegren on 25/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit

protocol FileSystemObject: class {
    
    var path: String {get set}
    var name: String {get}
    var menuName: String {get}
    var image: NSImage? {get}
    var debugDescription: String {get}
    
    func removeExtendedAttributes()
    
    weak var parent: Directory? {get set}
}

class ResultCache<InputType: Hashable, ResultType> {
    
    var cache = Dictionary<InputType, ResultType>()
    let calculationHandler: (InputType) -> ResultType
    
    init(calculationHandler: @escaping (InputType) -> ResultType) {
        self.calculationHandler = calculationHandler
    }
    
    func calculateResult(input: InputType) -> ResultType {
        
        if let storedValue = cache[input] {
            return storedValue
        }
        else {
            let calculatedValue = calculationHandler(input)
            cache[input] = calculatedValue
            return calculatedValue
        }
    }
}

class Directory: FileSystemObject {
    
    class ExtendedDictionaryAttributes {
        var containedFileNames = [String]()
        var containedFolderNames = [String]()
        
        var containsFilesWithFullNameResultCache: ResultCache<String, Bool>!
        var containsFilesWithExtensionResultCache: ResultCache<String, Bool>!
        var containsFoldersWithNameResultCache: ResultCache<String, Bool>!

        init() {
            
            // Contains files with full name cache
            containsFilesWithFullNameResultCache = ResultCache<String, Bool>{
                for fileName in self.containedFileNames {
                    if fileName == $0 {
                        return true
                    }
                }
                return false
            }
            
            // Contains files with extension cache
            containsFilesWithExtensionResultCache = ResultCache<String, Bool>{
                for fileName in self.containedFileNames {
                    
                    let components = fileName.components(separatedBy: ".")
                    
                    if components.count == 2 && components.last! == $0 {
                        return true
                    }
                }
                return false
            }
            
            // Contains folders with name cache
            containsFoldersWithNameResultCache = ResultCache<String, Bool>{
                for folderName in self.containedFolderNames {
                    if folderName == $0 {
                        return true
                    }
                }
                return false
            }
        }
        
        func containsFiles(withFullName name: String) -> Bool {
            return containsFilesWithFullNameResultCache.calculateResult(input: name)
        }
        
        func containsFiles(withExtension ext: String) -> Bool {
            return containsFilesWithExtensionResultCache.calculateResult(input: ext)
        }
        
        func containsFolders(withName name: String) -> Bool {
            return containsFoldersWithNameResultCache.calculateResult(input: name)
        }
    }
    var extendedAttributes: ExtendedDictionaryAttributes?
    
    var name: String
    var contents = [FileSystemObject]()
    var path: String
    var image: NSImage?
    weak var parent: Directory?
    
    var debugDescription: String {
        return name
    }
    
    var menuName: String {
        return name
    }
    
    var containedFiles: [File] {
        return contents.flatMap{ $0 as? File }
    }
    
    var containedDirectories: [Directory] {
        return contents.flatMap{ $0 as? Directory }
    }
    
    init(name: String, path: String) {
        self.name = name
        self.path = path
    }
    
    func add(object: FileSystemObject){
        contents.append(object)
    }
    
    func printHeirarchy() {
        printHeirarchyRecursive(indent: 0)
    }
    
    private func printHeirarchyRecursive(indent: Int) {
        
        let spaces = (0..<indent).reduce(""){ (result, _) in result + "  "}
        print("\(spaces) - [\(debugDescription)]")
        
        for object in contents {
            
            if let innerDir = object as? Directory {
                innerDir.printHeirarchyRecursive(indent: indent + 1)
            }
            else{
                print("\(spaces) - \(object.debugDescription)")
            }
        }
    }
    
    func removeExtendedAttributes() {
        extendedAttributes = nil
        contents.forEach{
            $0.removeExtendedAttributes()
        }
    }
}

class File: FileSystemObject {
    
    let name: String
    let ext: String
    var path: String
    var image: NSImage?
    weak var parent: Directory?
    
    var debugDescription: String {
        return name + "." + ext
    }
    
    var menuName: String {
        
        if ext.characters.count > 0 {
            return "\(name)" + "." + "\(ext)"
        }
        else{
            return name
        }
        
    }
    
    var fullName: String {
        
        if ext.characters.count > 0 {
            return "\(name).\(ext)"
        }
        else{
            return name
        }
    }
    
    init(name: String, ext: String, path: String) {
        self.name = name
        self.ext = ext
        self.path = path
    }
    
    func removeExtendedAttributes() {
        // Do nothing, Files don't have extended attributes (yet!)
    }
}
