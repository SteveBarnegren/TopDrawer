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
    
    let includePngRules = [FileRule(target: .files(name: nil, ext: "png"), filter: .include)]

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
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           rules: includePngRules,
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "cat.png"))
        XCTAssertTrue(directory.containsObject(atPath: "TestFolder/dog.png"))
        
        XCTAssertFalse(directory.containsObject(atPath: "document.pdf"))
        XCTAssertFalse(directory.containsObject(atPath: "TestFolder/report.pdf"))
    }
    
    func testIncludesOnlyMatchingDirectories() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .folder("IncludeFolder", [
                    .file("dog.png"),
                    ]),
                .folder("ExcludeFolder", [
                    .file("dog.png"),
                    ]),
                ])
        )
        
        let rules = [
            FileRule(target: .files(name: nil, ext: "png"), filter: .include),
            FileRule(target: .folders(name: "ExcludeFolder"), filter: .exclude)
        ]
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           rules: rules,
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "IncludeFolder/dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "ExcludeFolder/dogt.png"))
    }

    
    func testExcludeRulesOverrideIncludeRules() {
        
        let fileReader = MockFileReader(
            .folder( "Root", [
                .file("cat.png"),
                .file("dog.png"),
                .file("bird.png"),
                .folder("TestFolder", [
                    .file("cat.png"),
                    .file("dog.png"),
                    .file("bird.png"),
                    ]),
                ])
        )
        
        let rules = [
            FileRule(target: .files(name: nil, ext: "png"), filter: .include),
            FileRule(target: .files(name: "dog", ext: nil), filter: .exclude),
            ]
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           rules: rules,
                                           options: [])
        let directory = builder.buildFileSystemStructure(atPath: "Root")!
        
        XCTAssertTrue(directory.containsObject(atPath: "cat.png"))
        XCTAssertTrue(directory.containsObject(atPath: "bird.png"))
        XCTAssertTrue(directory.containsObject(atPath: "TestFolder/cat.png"))
        XCTAssertTrue(directory.containsObject(atPath: "TestFolder/bird.png"))

        XCTAssertFalse(directory.containsObject(atPath: "dog.png"))
        XCTAssertFalse(directory.containsObject(atPath: "TestFolder/dog.png"))
    }

}
