//
//  FileSystem.swift
//  MenuNav
//
//  Created by Steve Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

protocol FileSystemObject {
    var name: String {get}
}

struct Directory: FileSystemObject {
    
    let name: String
    var contents = [FileSystemObject]()
    
    init(name: String) {
        self.name = name
    }
    
    mutating func add(object: FileSystemObject){
        contents.append(object)
    }
}

struct File: FileSystemObject {
    
    let name: String
    let ext: String
    
    init(name: String, ext: String) {
        self.name = name
        self.ext = ext
    }
    
    
}


class FileSystem {

    // MARK: - Internal
    var acceptedFileTypes = [String]()
    
    func buildFileSystemStructure(atPath path: String) -> Directory {
        return fileSystemObject(atPath: path) as! Directory
    }
    
    // MARK: - Build Directory Structure
    
    private func fileSystemObject(atPath path: String) -> FileSystemObject? {
        
        print("path: \(path)")
        
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        
        guard exists else{
            return nil
        }
        
        if isDirectory.boolValue {
            
            let name = path.components(separatedBy: "/").last!
            var directory = Directory(name: name)
            
            guard let contents = try? fileManager.contentsOfDirectory(atPath: path) else {
                return directory
            }
            
            contents.map{ "\(path)" + "/" + $0 }
                .flatMap{ fileSystemObject(atPath: $0) }
                .forEach{
                    directory.add(object: $0)
            }
            
            return directory
        }
        else{
            
            let nameWithExtension = path.components(separatedBy: "/").last!
            let name = nameWithExtension.deletingPathExtension()
            let ext = nameWithExtension.pathExtension
            
            guard acceptedFileTypes.contains(ext) else {
                return nil
            }
            
            let file = File(name: name.deletingPathExtension(),
                            ext: name.pathExtension)
            
            return file
        }
        
    }

    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    
   
    
}
