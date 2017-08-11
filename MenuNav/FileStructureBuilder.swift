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
    
    // MARK: - Types
    
    struct Options : OptionSet {
        let rawValue: Int
        
        static let removeEmptyFolders = Options(rawValue: 1 << 0)
        static let shortenPaths = Options(rawValue: 1 << 1)
    }
    
    // MARK: - Init
    
    init(fileReader: FileReader,
         fileRules: [FileRule],
         folderRules: [FolderRule],
         options: Options) {
        
        self.fileRules = fileRules
        self.folderRules = folderRules
        self.fileReader = fileReader
        self.options = options
    }

    // MARK: - Properties
    
    private let fileRules: [FileRule]
    private let folderRules: [FolderRule]
    private let fileReader: FileReader
    private let options: Options
    
    // MARK: - Build Directory Structure
    
    func buildFileSystemStructure(atPath path: String) -> Directory? {
        
        // Get File Structure
        guard var rootDirectory = fileSystemObject(atPath: path) as? Directory else {
            return nil
        }
        
        // Only show folders with matching files?
        if options.contains(.removeEmptyFolders) {
            rootDirectory = directoryByRemovingDeadPaths(inDirectory: rootDirectory)
        }
        
        // Shorten paths?
        if options.contains(.shortenPaths) {
            rootDirectory = directoryByShorteningPaths(inDirectory: rootDirectory)
        }
        
        return rootDirectory
    }
    
    private func fileSystemObject(atPath path: String) -> FileSystemObject? {
        
        let pathComponents = path.components(separatedBy: "/")
        let itemName = pathComponents.last!
        let isBaseDirectory = pathComponents.count == 1
        
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
            
            if !isBaseDirectory && shouldExclude(directory: directory) {
                return nil
            }
            
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
    
    private func doesDirectoryContainAcceptedFiles(_ directory: Directory) -> Bool {
        
        for file in directory.containedFiles {
            if shouldInclude(file: file) {
                return true
            }
        }
        
        return false
    }
    
    private func shouldInclude(file: File) -> Bool {

        for rule in fileRules {
            
            if rule.includes(file: file) {
                return true
            }
        }
        
        return false
    }
    
    private func shouldExclude(directory: Directory) -> Bool {
        
        for rule in folderRules {
            
            if rule.excludes(directory: directory) {
                return true
            }
        }
        
        return false
    }
    
    func imageForPath(_ path: String) -> NSImage {
        let image = NSWorkspace.shared().icon(forFile: path)
        image.size = CGSize(width: image.size.width/2, height: image.size.height/2)
        return image
    }
    
}
