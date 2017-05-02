//
//  FileType.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/05/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

public struct FileType {
    
    let name: String?
    let ext: String?
    let exclude: Bool
    
    init(name: String?, ext: String?, exclude: Bool) {
        
        var name = name
        var ext = ext

        if let n = name, n.length == 0 {
            name = nil
        }
        
        if let e = ext, e.length == 0 {
            ext = nil
        }
        
        if name == nil && ext == nil {
            fatalError("FileType must have non nil name or ext")
        }
        
        self.name = name
        self.ext = ext
        self.exclude = exclude
    }
    
    func includesFile(withName name: String, ext: String) -> Bool {
        
        if self.exclude {
            return false
        }
        
        return matchesFile(withName: name, ext: ext)
    }
    
    func excludesFile(withName name: String, ext: String) -> Bool {
        
        if self.exclude {
            return matchesFile(withName: name, ext: ext)
        }
        
        return false
    }
    
    var displayName: String{
        
        let name = self.name ?? "*"
        let ext = self.ext ?? "*"
        let fileName = name + "." + ext
        
        if exclude {
            return fileName + " (!)"
        }
        else{
            return fileName
        }
    }
    
    // MARK: - Matching
    
    private func matchesFile(withName name: String, ext: String) -> Bool {
        
        switch (self.name, self.ext) {
        case (.some, nil):
            if self.name == name {
                return true
            }
        case (nil, .some):
            if self.ext == ext {
                return true
            }

        case (.some, .some):
            if self.name == name && self.ext == ext {
                return true
            }
            
        case (nil, nil):
            return true
        }
        
        return false
    }
    
    // MARK: - String Representation
    
    init?(stringRepresentation: String) {
        
        var stringRepresentation = stringRepresentation
        
        if stringRepresentation.length == 0 {
            return nil
        }
        
        // is excluding?
        if stringRepresentation.characters.first! == "." {
            exclude = true
            
            let index = stringRepresentation.index(stringRepresentation.startIndex, offsetBy: 1)
            stringRepresentation = stringRepresentation.substring(from: index)
        }
        else{
            exclude = false
        }
        
        // Get name and extension
        
        let components = stringRepresentation.components(separatedBy: ".")
        
        if components.count != 2 {
            return nil
        }
        
        var n = components.first
        var e = components.last
        
        if n == "*" {
            n = nil
        }

        if e == "*" {
            e = nil
        }
        
        name = n
        ext = e
        
        if name == nil && ext == nil {
            return nil
        }
    }
    
    func stringRepresentation() -> String {
        
        let name = self.name ?? "*"
        let ext = self.ext ?? "*"
        let fileName = name + "." + ext
        
        if exclude {
            return "." + fileName
        }
        else{
            return fileName
        }
    }
}
