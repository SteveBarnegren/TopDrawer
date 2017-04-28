//
//  FileSystem.swift
//  MenuNav
//
//  Created by Steve Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

protocol FileSystemObject {
    var path: String {get set}
    var name: String {get}
    var menuName: String {get}
}

struct Directory: FileSystemObject {
    
    let name: String
    var contents = [FileSystemObject]()
    var path: String
    
    var menuName: String {
        return name
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


class FileSystem {

    // MARK: - Internal
    var acceptedFileTypes = [String]()
    let knownContainerTypes = ["xcodeproj", "xcworkspace", "xcassets", "lproj"]
    
    func buildFileSystemStructure(atPath path: String) -> Directory {
        return fileSystemObject(atPath: path) as! Directory
    }
    
    // MARK: - Build Directory Structure
    
    private func fileSystemObject(atPath path: String) -> FileSystemObject? {
        
        print("path: \(path)")

        let itemName = path.components(separatedBy: "/").last!
        
        // Filter hidden files
        if itemName.characters.count > 0, itemName.characters.first == "." {
            return nil
        }
        
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        
        guard exists else{
            return nil
        }
        
        var isPackage = false
        
        knownContainerTypes.forEach {
            if itemName.contains($0) {
                isPackage = true
            }
        }
        
        if isPackage {
         
            let nameWithExtension = path.components(separatedBy: "/").last!
            
            let file = File(name: nameWithExtension,
                            ext: "",
                            path: path)
    
            return file
        }
        else if isDirectory.boolValue {
            
            let name = path.components(separatedBy: "/").last!
            var directory = Directory(name: name,
                                      path: path)
            
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
                            ext: name.pathExtension,
                            path: path)
            
            return file
        }
        
    }

    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    
   
    
}
