//
//  FileSystemObject.swift
//  MenuNav
//
//  Created by Steve Barnegren on 25/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit

protocol FileSystemObject {
    var path: String {get set}
    var name: String {get}
    var menuName: String {get}
    var image: NSImage? {get}
}

struct Directory: FileSystemObject {
    
    var name: String
    var contents = [FileSystemObject]()
    var path: String
    var image: NSImage?
    
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
    
    mutating func add(object: FileSystemObject){
        contents.append(object)
    }
    
}

struct File: FileSystemObject {
    
    let name: String
    let ext: String
    var path: String
    var image: NSImage?
    
    var menuName: String {
        
        if ext.characters.count > 0 {
            return "\(name)" + "." + "\(ext)"
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
}
