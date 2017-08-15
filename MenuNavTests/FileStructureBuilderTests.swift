//
//  FileStructureBuilderTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 29/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

// MARK: - ****** FileReaderMock ******

enum MockFileObject {
    case file(String)
    indirect case folder(String, [MockFileObject])
    
    var name: String {
        switch self {
        case let .file(name):
            return name
        case let .folder(name, _):
            return name
        }
    }
    
    func getObject(atPath path: String) -> MockFileObject? {
        
        let objectNames = path.components(separatedBy: "/")
        let nextObjectName = objectNames.first!
        let remainingPath = objectNames.dropFirst().joined(separator: "/")

        switch self {
        case .file(_):
            return nil
        case let .folder(_, contents):
            
            // Check if we have the object (if we're the last in the path)
            if objectNames.count == 1 {
                return contents.first(where: {
                    $0.name == nextObjectName
                })
            }
            
            // Check in our contents
            return contents.first(where: {
                $0.name == nextObjectName
            })?.getObject(atPath: remainingPath)
        }
    }
    
    func printHeirarchy() {
        printHeirarchyRecursive(indent: 0)
    }
    
    func printHeirarchyRecursive(indent: Int) {
        
        let spaces = (0..<indent).reduce(""){ (result, _) in result + " "}
        
        switch self {
        case let .file(name):
            print("\(spaces) - \(name)")
        case let .folder(name, contents):
            print("\(spaces) - [\(name)]")
            contents.forEach{
                $0.printHeirarchyRecursive(indent: indent + 1)
            }
        }
    }
}

class MockFileReader: FileReader {
    
    let rootFileObject: MockFileObject
    
    init(_ rootObject: MockFileObject) {
        self.rootFileObject = rootObject
    }
    
    func fileExists(atPath path: String, isDirectory: UnsafeMutablePointer<ObjCBool>?) -> Bool {
        
        guard let object = getObject(atPath: path) else {
            return false
        }
    
        switch object {
        case .file(_):
            isDirectory?.pointee = false
        case .folder(_, _):
            isDirectory?.pointee = true
        }
    
        return true
    }
    
    func contentsOfDirectory(atPath path: String) throws -> [String] {
        
        // Should return the names of the objects, not the full paths
        
        guard let object = getObject(atPath: path) else {
            fatalError("Expected Object to exist")
        }
        
        switch object {
        case .file(_):
            fatalError("Expected Object to be directory")
        case let .folder(_, contents):
            return contents.map{ $0.name }
        }
    }
    
    private func getObject(atPath path: String) -> MockFileObject? {
        
        // Return the root object if the path is just to the root
        if path == rootFileObject.name {
            return rootFileObject
        }
        
        // Check we have the correct root
        let components = path.components(separatedBy: "/")
        let rootName = components.first!
        if rootFileObject.name != rootName {
            return nil
        }
        
        // Drop the root folder from the search path
        let path = components.dropFirst().joined(separator: "/")
        
        // Search the root object
        return rootFileObject.getObject(atPath: path)
    }
}

// MARK: - Directory Extensions

extension Directory {
    
    func containsObject(atPath path: String) -> Bool {
        
        let components = path.components(separatedBy: "/")
        
        if components.count == 0 {
            return false
        }
        else if components.count == 1 {
            
            let file = contents.flatMap{ $0 as? File }
                .first{ "\($0.name).\($0.ext)" == components.first!}
            
            return !(file == nil)
        }
        else {
            
            let directory = contents.flatMap{ $0 as? Directory }
                .first{ "\($0.name)" == components.first!}
            
            if let d = directory {
                let remainingPath = components.dropFirst().joined(separator: "/")
                return d.containsObject(atPath: remainingPath)
            }
            else{
                return false
            }
        }
    }
}

// MARK: - ****** FileStructureBuilderTests ******

class Tests: XCTestCase {
    
    func testIncludesOnlyMatchingFiles() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("cat.png"),
                .file("document.pdf"),
                .folder("TestFolder", [
                    .file("dog.png"),
                    .file("report.pdf"),
                    ]),
                ])
        )
        
        let matchPngRule = FileRule(conditions: [.ext(.matching("png"))])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [matchPngRule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "cat.png"))
        XCTAssertTrue(directory.containsObject(atPath: "TestFolder/dog.png"))
        
        XCTAssertFalse(directory.containsObject(atPath: "document.pdf"))
        XCTAssertFalse(directory.containsObject(atPath: "TestFolder/report.pdf"))
    }
    
    // MARK: - File Rules: Name
    
    func testStructureIncludesFilesWithName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("cat.png"),
                .file("dog.png"),
            ])
        )
        
        let condition = FileCondition.name(.matching("dog"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "cat.png"))
    }
    
    func testStructureIncludesFilesWithNameIsNot() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("cat.png"),
                .file("dog.png"),
            ])
        )
        
        let condition = FileCondition.name(.notMatching("dog"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertFalse(directory.containsObject(atPath: "dog.png"))
        XCTAssertTrue(directory.containsObject(atPath: "cat.png"))
    }
    
    func testStructureIncludesFilesWithNameContaining() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("a photo of a cat.png"),
                .file("a photo of a dog.png"),
            ])
        )
        
        let condition = FileCondition.name(.containing("dog"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "a photo of a dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "a photo of a cat.png"))
    }
    
    func testStructureIncludesFilesWithNameNotContaining() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("a photo of a cat.png"),
                .file("a photo of a dog.png"),
                ])
        )
        
        let condition = FileCondition.name(.notContaining("dog"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertFalse(directory.containsObject(atPath: "a photo of a dog.png"))
        XCTAssertTrue(directory.containsObject(atPath: "a photo of a cat.png"))
    }
    
    // MARK: - File Rules: Extension
    
    func testStructureIncludesFilesWithExtension() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("dog.png"),
                .file("cat.gif"),
                ])
        )
        
        let condition = FileCondition.ext(.matching("png"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "cat.gif"))
    }
    
    func testStructureIncludesFilesWithExtensionIsNot() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("dog.png"),
                .file("cat.gif"),
                ])
        )
        
        let condition = FileCondition.ext(.notMatching("png"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertFalse(directory.containsObject(atPath: "dog.png"))
        XCTAssertTrue(directory.containsObject(atPath: "cat.gif"))
    }
    
    // MARK: - File Rules: Full Name
    
    func testStructureIncludesFilesWithFullName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("dog.png"),
                .file("cat.gif"),
                ])
        )
        
        let condition = FileCondition.fullName(.matching("dog.png"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "cat.gif"))
    }
    
    func testStructureIncludesFilesWithFullNameIsNot() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("dog.png"),
                .file("cat.gif"),
                ])
        )
        
        let condition = FileCondition.fullName(.notMatching("dog.png"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertFalse(directory.containsObject(atPath: "dog.png"))
        XCTAssertTrue(directory.containsObject(atPath: "cat.gif"))
    }
    
    // MARK: - File Rules: Parent Contains
    
    func testStructureIncludesFilesWithParentContainsFilesWithExtension() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("ContainsGif", [
                    .file("cat.gif"),
                    .file("dog.png"),
                    ]),
                .folder("DoesntContainGif", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let condition = FileCondition.parentContains(.filesWithExtension("gif"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "ContainsGif/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "DoesntContainGif/dog.png"))
    }
    
    func testStructureIncludesFilesWithParentContainsFilesWithFullName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("ContainsGif", [
                    .file("cat.gif"),
                    .file("dog.png"),
                    ]),
                .folder("DoesntContainGif", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let condition = FileCondition.parentContains(.filesWithFullName("cat.gif"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "ContainsGif/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "DoesntContainGif/dog.png"))
    }
    
    // MARK: - File Rules: Parent Doesn't Contain
    
    func testStructureIncludesFilesWithParentDoesntContainFilesWithExtension() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("ContainsGif", [
                    .file("cat.gif"),
                    .file("dog.png"),
                    ]),
                .folder("DoesntContainGif", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let condition = FileCondition.parentDoesntContain(.filesWithExtension("gif"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertFalse(directory.containsObject(atPath: "ContainsGif/dog.png"))
        XCTAssertTrue(directory.containsObject(atPath: "DoesntContainGif/dog.png"))
    }
    
    func testStructureIncludesFilesWithParentDoesntContainFilesWithFullName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("ContainsGif", [
                    .file("cat.gif"),
                    .file("dog.png"),
                    ]),
                .folder("DoesntContainGif", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let condition = FileCondition.parentDoesntContain(.filesWithFullName("cat.gif"))
        let rule = FileRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: [rule],
                                           folderRules: [],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertFalse(directory.containsObject(atPath: "ContainsGif/dog.png"))
        XCTAssertTrue(directory.containsObject(atPath: "DoesntContainGif/dog.png"))
    }

    
    // MARK: - Folder Rules: Name
    
    func dogPngFileRules() -> [FileRule] {
        let condition = FileCondition.fullName(.matching("dog.png"))
        let rule = FileRule(conditions: [condition])
        return [rule]
    }
    
    func testStructureExcludesFoldersWithName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        
        let condition = FolderCondition.name(.matching("Exclude Me"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    func testStructureExcludesFoldersWithNameIsNot() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        
        let condition = FolderCondition.name(.notMatching("Include Me"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    func testStructureExcludesFoldersWithNameContaining() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("-- Include Me --", [
                    .file("dog.png"),
                    ]),
                .folder("-- Exclude Me --", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        
        let condition = FolderCondition.name(.containing("Exclude Me"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "-- Include Me --/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "-- Exclude Me --/dog.png"))
    }
    
    func testStructureExcludesFoldersWithNameNotContaining() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("-- Include Me --", [
                    .file("dog.png"),
                    ]),
                .folder("-- Exclude Me --", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        
        let condition = FolderCondition.name(.notContaining("Include Me"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "-- Include Me --/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "-- Exclude Me --/dog.png"))
    }
    
    // MARK: - Folder Rules: Path

    func testStructureExcludesFoldersWithPath() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        
        let condition = FolderCondition.path(.matching("Root/Exclude Me"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    func testStructureExcludesFoldersWithPathIsNot() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        
        let condition = FolderCondition.path(.notMatching("Root/Include Me"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    // MARK: - Folder Rules: Contains
    
    func testStructureExcludesFoldersWithContainsFilesWithExtension() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    .file("cat.gif"),
                    ]),
                ])
        )
        
        let condition = FolderCondition.contains(.filesWithExtension("gif"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    func testStructureExcludesFoldersWithContainsFilesWithFullName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    .file("cat.gif"),
                    ]),
                ])
        )
        
        let condition = FolderCondition.contains(.filesWithFullName("cat.gif"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    func testStructureExcludesFoldersWithContainsFoldersWithName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    ]),
                .folder("Exclude Me", [
                    .folder("A Folder", []),
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let condition = FolderCondition.contains(.foldersWithName("A Folder"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    // MARK: - Folder Rules: Doesn't Contain
    
    func testStructureExcludesFoldersWithDoesntContainFilesWithExtension() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    .file("cat.gif"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let condition = FolderCondition.doesntContain(.filesWithExtension("gif"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    func testStructureExcludesFoldersWithDoesntContainFilesWithFullName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .file("dog.png"),
                    .file("cat.gif"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let condition = FolderCondition.doesntContain(.filesWithFullName("cat.gif"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
    
    func testStructureExcludesFoldersWithDoesntContainFoldersWithName() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("Include Me", [
                    .folder("A Folder", []),
                    .file("dog.png"),
                    ]),
                .folder("Exclude Me", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let condition = FolderCondition.doesntContain(.foldersWithName("A Folder"))
        let rule = FolderRule(conditions: [condition])
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: dogPngFileRules(),
                                           folderRules: [rule],
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "Include Me/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "Exclude Me/dog.png"))
    }
}
