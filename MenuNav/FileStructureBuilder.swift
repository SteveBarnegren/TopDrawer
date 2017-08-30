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
    func resolveAlias(atPath path: String) -> String
}

extension FileManager: FileReader {

    func resolveAlias(atPath path: String) -> String {
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isAliasFileKey])
            if resourceValues.isAliasFile! {
                let original = try URL(resolvingAliasFileAt: url)
                return original.path
            }
        } catch  {
            print(error)
        }
        return path
    }
}

// MARK: - ****** FileStructureBuilder ******

class FileStructureBuilder {
    
    // MARK: - Types
    
    struct Options : OptionSet {
        let rawValue: Int
        static let shortenPaths = Options(rawValue: 1 << 0)
        static let followAliases = Options(rawValue: 1 << 1)
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
    
    var isCancelledHandler: () -> (Bool) = { return false }
    
    private let fileRules: [FileRule]
    private let folderRules: [FolderRule]
    private let fileReader: FileReader
    private let options: Options
    private var visitedFolderPaths = Set<String>()
    
    // MARK: - Build Directory Structure
    
    func buildFileSystemStructure(atPath path: String) -> Directory? {
        
        // Get File Structure
        guard var rootDirectory = fileSystemObject(atPath: path, withParent: nil) as? Directory else {
            return nil
        }
        
        // Check for cancelation
        if isCancelledHandler() == true { return nil }
        
        // Shorten paths?
        if options.contains(.shortenPaths) {
            rootDirectory = directoryByShorteningPaths(inDirectory: rootDirectory)
        }
        
        // Check for cancelation
        if isCancelledHandler() == true { return nil }
        
        // Remove extended attributes, only required for parsing, so we can remove them to keep the memory footprint low
        rootDirectory.removeExtendedAttributes()
        
        // Check for cancelation
        if isCancelledHandler() == true { return nil }
        
        return rootDirectory
    }
    
    private func fileSystemObject(atPath path: String, withParent parent: Directory?) -> FileSystemObject? {
        
        if isCancelledHandler() == true {
            return nil
        }
        
        var path = path
        var visibleName = path.components(separatedBy: "/").last!
        if options.contains(.followAliases) {
            path = fileReader.resolveAlias(atPath: path)
        }
        
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
            
            if visitedFolderPaths.contains(path) {
                return nil
            }
            visitedFolderPaths.insert(path)
            
            let directory = Directory(name: visibleName,
                                      path: path)
            
            guard let contents = try? fileReader.contentsOfDirectory(atPath: path) else {
                return directory
            }
            
            let extendedAttributes = Directory.ExtendedDictionaryAttributes()
            extendedAttributes.containedFileNames = contents.filter{ $0.contains(".") }
            extendedAttributes.containedFolderNames = contents.filter{ $0.contains(".") == false }
            directory.extendedAttributes = extendedAttributes
            
            if !isBaseDirectory && shouldExclude(directory: directory) {
                return nil
            }
            
            directory.image = imageForPath(path)
            
            contents.map{ "\(path)" + "/" + $0 }
                .flatMap{ fileSystemObject(atPath: $0, withParent: directory) }
                .forEach{
                    directory.add(object: $0)
            }
            
            return directory.contents.count > 0 ? directory : nil
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
            file.parent = parent

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
