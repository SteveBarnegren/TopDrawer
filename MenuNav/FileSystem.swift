//
//  FileSystem.swift
//  MenuNav
//
//  Created by Steve Barnegren on 28/04/2017.
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


class FileSystem {

    // MARK: - Internal
    var acceptedFileTypes = [FileType]()
    
    func buildFileSystemStructure(atPath path: String) -> Directory? {
        
        // Get File Structure
        guard var rootDirectory = fileSystemObject(atPath: path) as? Directory else {
            return nil
        }
        
        // Only show folders with matching files?
        if Settings.onlyShowFoldersWithMatchingFiles {
            rootDirectory = directoryByRemovingDeadPaths(inDirectory: rootDirectory)
        }
        
        // Shorten paths?
        if Settings.shortenPathsWherePossible {
            rootDirectory = directoryByShorteningPaths(inDirectory: rootDirectory)
        }
        
        return rootDirectory
    }
    
    // MARK: - Build Directory Structure
    
    private func fileSystemObject(atPath path: String) -> FileSystemObject? {
        
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
        if isDirectory.boolValue && itemName.contains(".") {
            isPackage = true
        }

        if isDirectory.boolValue && !isPackage {
            
            let name = path.components(separatedBy: "/").last!
            var directory = Directory(name: name,
                                      path: path)
            directory.image = imageForPath(path)
            
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
            
            let name: String
            let ext: String
            
            if isPackage {
                
                name = nameWithExtension.components(separatedBy: ".").first!
                ext = nameWithExtension.components(separatedBy: ".").last!
            }
            else{
                name = nameWithExtension.deletingPathExtension()
                ext = nameWithExtension.pathExtension
            }
            
            guard isAcceptedFileType(name: name, ext: ext) else {
                return nil
            }
            
            var file = File(name: name,
                            ext: ext,
                            path: path)
            file.image = imageForPath(path)
            
            return file
        }
        
    }
    
    // MARK: - Removing Dead paths
    
    func directoryByRemovingDeadPaths(inDirectory directory: Directory) -> Directory {
        
        var newContents = [FileSystemObject]()
        
        for file in directory.containedFiles {
            newContents.append(file)
        }
        
        for innerDir in directory.containedDirectories {
            if doesDirectoryLeadToAcceptedFileType(innerDir) {
                newContents.append(directoryByRemovingDeadPaths(inDirectory: innerDir))
            }
        }
        
        var newDirectory = directory
        newDirectory.contents = newContents
        
        return newDirectory
    }
    
    func doesDirectoryLeadToAcceptedFileType(_ directory: Directory) -> Bool {
        
        for file in directory.containedFiles {
            if isAcceptedFileType(name: file.name, ext: file.ext) {
                return true
            }
        }
        
        for innerDir in directory.containedDirectories {
            
            if doesDirectoryLeadToAcceptedFileType(innerDir) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Shortening Paths
    
    func directoryByShorteningPaths(inDirectory directory: Directory) -> Directory {
        
        var newContents = [FileSystemObject]()
        
        directory.containedFiles.forEach {
            newContents.append($0)
        }
        
        
        for innerDir in directory.containedDirectories {
            
            if innerDir.containedFiles.count == 0 && innerDir.containedDirectories.count == 1 {
                
                for innerDirDir in innerDir.containedDirectories {
                    var newDir = directoryByShorteningPaths(inDirectory: innerDirDir)
                    newDir.name = innerDir.name
                    newContents.append(newDir)
                }
            }
            else{
                newContents.append(directoryByShorteningPaths(inDirectory: innerDir))
            }
        }
        
        var newDirectory = directory
        newDirectory.contents = newContents
        return newDirectory
        
    }
    
    // MARK: - Helpers
    
    func doesDirectoryContainAcceptedFiles(_ directory: Directory) -> Bool {
        
        for file in directory.containedFiles {
            if isAcceptedFileType(name: file.name, ext: file.ext) {
                return true
            }
        }
        
        return false
    }
    
    func isAcceptedFileType(name: String, ext: String) -> Bool {
        
        var include = false
        var exclude = false
        
        for fileType in acceptedFileTypes {
            
            if fileType.includesFile(withName: name, ext: ext) {
                include = true
            }
            
            if fileType.excludesFile(withName: name, ext: ext) {
                exclude = true
            }
        }
        
        return (include && !exclude)
    }
    
    func imageForPath(_ path: String) -> NSImage {
        let image = NSWorkspace.shared().icon(forFile: path)
        image.size = CGSize(width: image.size.width/2, height: image.size.height/2)
        return image
    }

    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    
   
    
}
