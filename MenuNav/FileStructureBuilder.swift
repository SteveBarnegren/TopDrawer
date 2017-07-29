//
//  FileSystem.swift
//  MenuNav
//
//  Created by Steve Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit

// MARK: - ****** FileReader ******

protocol FileReader: class {
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool
    func contentsOfDirectory(atPath path: String) throws -> [String]
}

extension FileManager: FileReader {}

// MARK: - ****** FileStructureBuilder ******

class FileStructureBuilder {
    
    // MARK: - Init
    
    init(fileReader: FileReader, rules: [FileRule]) {
        self.rules = rules
        self.fileReader = fileReader
    }

    // MARK: - Properties
    
    private let rules: [FileRule]
    private let fileReader: FileReader
    
    // MARK: - Build Directory Structure
    
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
    
    private func fileSystemObject(atPath path: String) -> FileSystemObject? {
        
        let itemName = path.components(separatedBy: "/").last!
        
        // Filter hidden files
        if itemName.characters.count > 0, itemName.characters.first == "." {
            return nil
        }
        
        var isDirectory: ObjCBool = false
        let exists = fileReader.fileExists(atPath: path, isDirectory: &isDirectory)
        
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
            
            guard let contents = try? fileReader.contentsOfDirectory(atPath: path) else {
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
            
            var file = File(name: name,
                            ext: ext,
                            path: path)

            guard shouldInclude(file: file) else {
                return nil
            }
            
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
            if shouldInclude(file: file) {
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
            if shouldInclude(file: file) {
                return true
            }
        }
        
        return false
    }
    
    func shouldInclude(file: File) -> Bool {
        
        var include = false
        var exclude = false

        for rule in rules {
            
            if rule.includes(file: file) {
                include = true
            }

            if rule.excludes(file: file) {
                exclude = true
            }
        }
        
        return (include && !exclude)
    }
    
//    func isAcceptedFileType(name: String, ext: String) -> Bool {
//        
//        var include = false
//        var exclude = false
//        
//        for rule in rules {
//            
//            /*
//            if rule.includesFile(withName: name, ext: ext) {
//                include = true
//            }
//            
//            if rule.excludesFile(withName: name, ext: ext) {
//                exclude = true
//            }
// */
//        }
//        
//        return (include && !exclude)
//    }
    
    func imageForPath(_ path: String) -> NSImage {
        let image = NSWorkspace.shared().icon(forFile: path)
        image.size = CGSize(width: image.size.width/2, height: image.size.height/2)
        return image
    }

}
