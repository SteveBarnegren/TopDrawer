//
//  TestDirectoryBuilder.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

class TestDirectoryBuilder {
    
    // MARK: - Make Directories
    
    static func makeDirectory(withFileNames fileNames: [String]) -> Directory {
        return makeDirectory(fileNames: fileNames, folderNames: [])
    }
    
    static func makeDirectory(withFolderNames folderNames: [String]) -> Directory {
        return makeDirectory(fileNames: [], folderNames: folderNames)
    }
    
    static func makeDirectory(fileNames: [String], folderNames: [String]) -> Directory {
        
        let directory = Directory(name: "dir", path: "root/dir")
        
        let files = fileNames.map{ (string: String) -> File in
            
            let components = string.components(separatedBy: ".")
            assert(components.count == 2, "Expected a name and extension")
            let path = "root/dir/\(string)"
            return File(name: components[0], ext: components[1], path: path)
        }
        
        let folders = folderNames.map{ (string: String) -> Directory in
            let path = "root/dir/\(string)"
            return Directory(name: string, path: path)
        }
        
        var contents = [FileSystemObject]()
        contents.append(contentsOf: files.map{ $0 as FileSystemObject })
        contents.append(contentsOf: folders.map{ $0 as FileSystemObject })
        directory.contents = contents
        
        let extendedAttributes = Directory.ExtendedDictionaryAttributes()
        extendedAttributes.containedFileNames = fileNames
        extendedAttributes.containedFolderNames = folderNames
        directory.extendedAttributes = extendedAttributes
        
        return directory
    }
}
