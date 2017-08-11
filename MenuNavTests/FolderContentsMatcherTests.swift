//
//  FolderContentsMatcherTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

class FolderContentsMatcherTests: XCTestCase {
    
    // MARK: - Helpers
    
    func makeDirectory(withFileNames fileNames: [String]) -> Directory {
        return makeDirectory(fileNames: fileNames, folderNames: [])
    }

    func makeDirectory(withFolderNames folderNames: [String]) -> Directory {
        return makeDirectory(fileNames: [], folderNames: folderNames)
    }
    
    func makeDirectory(fileNames: [String], folderNames: [String]) -> Directory {
        
        var directory = Directory(name: "dir", path: "root/dir")
        
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
        
        return directory
    }
    
    
    // MARK: - Test Matching
    
    func testMatchesFilesWithExtension() {
        
        let folder = makeDirectory(withFileNames: ["dog.png"])
        let matcher = FolderContentsMatcher.filesWithExtension("png")
        
        XCTAssertTrue(matcher.matches(directory: folder))
    }
    
    func testFailsToMatchFilesWithExtension() {
        
        let folder = makeDirectory(withFileNames: ["dog.gif"])
        let matcher = FolderContentsMatcher.filesWithExtension("png")
        
        XCTAssertFalse(matcher.matches(directory: folder))
    }
    
    func testMatchesFilesWithNameAndExtension() {
        
        let folder = makeDirectory(withFileNames: ["dog.png"])
        let matcher = FolderContentsMatcher.filesWithNameAndExtension(name: "dog", ext: "png")
        
        XCTAssertTrue(matcher.matches(directory: folder))
    }
    
    func testFailsToMatchFilesWithNameAndExtension() {
        
        let folder = makeDirectory(withFileNames: ["dog.gif", "cat.png"])
        let matcher = FolderContentsMatcher.filesWithNameAndExtension(name: "dog", ext: "png")
        
        XCTAssertFalse(matcher.matches(directory: folder))
    }
    
    func testMatchesFoldersWithName() {
        
        let folder = makeDirectory(withFolderNames: ["animals"])
        let matcher = FolderContentsMatcher.foldersWithName("animals")
        
        XCTAssertTrue(matcher.matches(directory: folder))
    }
    
    func testFailsToMatchFoldersWithName() {
        
        let folder = makeDirectory(withFolderNames: ["no animals here"])
        let matcher = FolderContentsMatcher.foldersWithName("animals")
        
        XCTAssertFalse(matcher.matches(directory: folder))
    }
    
    // MARK: - Test Equatable
    
    func testFolderContentsMatchersAreEqualWithFilesWithExtensionCaseAndSameString() {
        
        let firstMatcher = FolderContentsMatcher.filesWithExtension("png")
        let secondMatcher = FolderContentsMatcher.filesWithExtension("png")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testFolderContentsMatchersAreNotEqualWithFilesWithExtensionCaseAndDifferentString() {
        
        let firstMatcher = FolderContentsMatcher.filesWithExtension("png")
        let secondMatcher = FolderContentsMatcher.filesWithExtension("pdf")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    func testFolderContentsMatchersAreEqualWithFullNameCaseAndSameString() {
        
        let firstMatcher = FolderContentsMatcher.filesWithNameAndExtension(name: "dog", ext: "png")
        let secondMatcher = FolderContentsMatcher.filesWithNameAndExtension(name: "dog", ext: "png")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testFolderContentsMatchersAreNotEqualWithFullNameCaseAndDifferentString() {
        
        let firstMatcher = FolderContentsMatcher.filesWithNameAndExtension(name: "dog", ext: "png")
        let differentNameMatcher = FolderContentsMatcher.filesWithNameAndExtension(name: "cat", ext: "png")
        let differentExtMatcher = FolderContentsMatcher.filesWithNameAndExtension(name: "dog", ext: "pdf")
        
        XCTAssertFalse(firstMatcher == differentNameMatcher)
        XCTAssertFalse(firstMatcher == differentExtMatcher)
    }
    
    func testFolderContentsMatchersAreEqualWithFolderNameCaseAndSameString() {
        
        let firstMatcher = FolderContentsMatcher.foldersWithName("animals")
        let secondMatcher = FolderContentsMatcher.foldersWithName("animals")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testFolderContentsMatchersAreNotEqualWithFolderNameCaseAndDifferentString() {
        
        let firstMatcher = FolderContentsMatcher.foldersWithName("animals")
        let secondMatcher = FolderContentsMatcher.foldersWithName("no animals here")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }

    // MARK: - Test DictionaryRepresentable
    
    func testFolderContentsMatcherToDictionaryAndBackIsSame() {
        
        let filesWithExtension = FolderContentsMatcher.filesWithExtension("pdf")
        let filesWithNameAndExtension = FolderContentsMatcher.filesWithNameAndExtension(name: "dog", ext: "png")
        let foldersWithName = FolderContentsMatcher.foldersWithName("animals")
        
        XCTAssertTrue(filesWithExtension == filesWithExtension.convertedToDictionaryAndBack)
        XCTAssertTrue(filesWithNameAndExtension == filesWithNameAndExtension.convertedToDictionaryAndBack)
        XCTAssertTrue(foldersWithName == foldersWithName.convertedToDictionaryAndBack)
    }

}
