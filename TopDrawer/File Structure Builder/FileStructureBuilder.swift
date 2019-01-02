//
//  FileSystem.swift
//  MenuNav
//
//  Created by Steve Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

// swiftlint:disable function_body_length

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
        } catch {
            print(error)
        }
        return path
    }
}

// MARK: - IconProvider

protocol IconProvider {
    func icon(forPath path: String) -> NSImage
}

class WorkspaceIconProvider: IconProvider {
    
    func icon(forPath path: String) -> NSImage {
        let image = NSWorkspace.shared.icon(forFile: path)
        image.size = CGSize(width: image.size.width/2, height: image.size.height/2)
        return image
    }
}

// MARK: - ****** FileStructureBuilder ******

enum FileStructureBuilderError: Error {
    case invalidRootPath
    case cancelled
    case noMatchingFiles
}

class FileStructureBuilder {
    
    // MARK: - Types
    
    struct Options: OptionSet {
        let rawValue: Int
        static let shortenPaths = Options(rawValue: 1 << 0)
        static let followAliases = Options(rawValue: 1 << 1)
    }
    
    // MARK: - Init
    
    init(fileReader: FileReader,
         fileRules: [FileRule],
         folderRules: [FolderRule],
         options: Options,
         iconProvider: IconProvider) {
        
        self.fileRules = fileRules
        self.folderRules = folderRules
        self.fileReader = fileReader
        self.options = options
        self.iconProvider = iconProvider
    }

    // MARK: - Properties
    
    var isCancelledHandler: () -> (Bool) = { return false }
    
    private let fileRules: [FileRule]
    private let folderRules: [FolderRule]
    private let fileReader: FileReader
    private let options: Options
    private let iconProvider: IconProvider
    private var visitedFolderPaths = Set<String>()
    
    // MARK: - Build Directory Structure
    
    func buildFileSystemStructure(atPath path: String) throws -> Directory {
        
        // Check that the directory actually exists
        var isDirectory: ObjCBool = false
        let exists = fileReader.fileExists(atPath: path, isDirectory: &isDirectory)
        if exists == false || isDirectory.boolValue == false {
            throw FileStructureBuilderError.invalidRootPath
        }
        
        // Get File Structure
        guard var rootDirectory = fileSystemObject(atPath: path,
                                                   withParent: nil,
                                                   hierarchyInfo: HierarchyInformation()) as? Directory else {
            throw FileStructureBuilderError.noMatchingFiles
        }
        
        // Check for cancelation
        if isCancelledHandler() == true { throw FileStructureBuilderError.cancelled }
        
        // Shorten paths?
        if options.contains(.shortenPaths) {
            rootDirectory = directoryByShorteningPaths(inDirectory: rootDirectory)
        }
        
        // Check for cancelation
        if isCancelledHandler() == true { throw FileStructureBuilderError.cancelled }
        
        // Remove extended attributes, only required for parsing,
        // so we can remove them to keep the memory footprint low
        rootDirectory.removeExtendedAttributes()
        
        // Check for cancelation
        if isCancelledHandler() == true { throw FileStructureBuilderError.cancelled }
        
        // Check if the directory is empty
        if rootDirectory.contents.isEmpty {
            throw FileStructureBuilderError.noMatchingFiles
        }
        
        return rootDirectory
    }
    
    private func fileSystemObject(atPath path: String,
                                  withParent parent: Directory?,
                                  hierarchyInfo: HierarchyInformation) -> FileSystemObject? {
        var hierarchyInfo = hierarchyInfo
        
        if isCancelledHandler() == true {
            return nil
        }
        
        var path = path
        let visibleName = path.components(separatedBy: "/").last!
        if options.contains(.followAliases) {
            path = fileReader.resolveAlias(atPath: path)
        }
        
        let pathComponents = path.components(separatedBy: "/")
        let itemName = pathComponents.last!
        let isBaseDirectory = pathComponents.count == 1
        
        // Filter hidden files
        if itemName.count > 0, itemName.first == "." {
            return nil
        }
        
        var isDirectory: ObjCBool = false
        let exists = fileReader.fileExists(atPath: path, isDirectory: &isDirectory)
        
        guard exists else {
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
            extendedAttributes.containedFileNames = contents.filter { $0.contains(".") }
            extendedAttributes.containedFolderNames = contents.filter { $0.contains(".") == false }
            directory.extendedAttributes = extendedAttributes
            
            if !isBaseDirectory && shouldExclude(directory: directory) {
                return nil
            }
            
            directory.image = iconProvider.icon(forPath: path)
            hierarchyInfo.add(folderName: directory.name)
            
            contents
                .sortedAscending()
                .map { "\(path)" + "/" + $0 }
                .compactMap { fileSystemObject(atPath: $0, withParent: directory, hierarchyInfo: hierarchyInfo) }
                .forEach { directory.add(object: $0) }
            
            return directory.contents.count > 0 ? directory : nil
        } else {
            
            let nameWithExtension = path.components(separatedBy: "/").last!
            
            let name: String
            let ext: String
            
            if isPackage {
                
                name = nameWithExtension.components(separatedBy: ".").first!
                ext = nameWithExtension.components(separatedBy: ".").last!
            } else {
                name = nameWithExtension.deletingPathExtension()
                ext = nameWithExtension.pathExtension
            }
            
            let file = File(name: name,
                            ext: ext,
                            path: path)
            file.parent = parent

            guard shouldInclude(file: file, inHierarchy: hierarchyInfo) else {
                return nil
            }
            
            file.image = iconProvider.icon(forPath: path)

            return file
        }
        
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
                    let newDir = directoryByShorteningPaths(inDirectory: innerDirDir)
                    newDir.name = innerDir.name
                    newContents.append(newDir)
                }
            } else {
                newContents.append(directoryByShorteningPaths(inDirectory: innerDir))
            }
        }
        
        let newDirectory = directory
        newDirectory.contents = newContents
        return newDirectory
        
    }
    
    // MARK: - Helpers
    
    private func shouldInclude(file: File, inHierarchy hierarchyInfo: HierarchyInformation) -> Bool {

        for rule in fileRules {
            
            if rule.includes(file: file, inHierarchy: hierarchyInfo) {
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
}
