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

class Directory: FileSystemObject {
    
    class ExtendedDictionaryAttributes {
        var containedFileNames = [String]()
        var containedFolderNames = [String]()
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
