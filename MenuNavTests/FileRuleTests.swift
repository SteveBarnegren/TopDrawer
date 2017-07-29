//
//  FileRuleTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 29/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest
@testable import MenuNav

class FileRuleTests: XCTestCase {
    
    // MARK: - Test FileRule.Target Equatable
    
    func testFileRuleTargetsAreEqualWhenTargetIsFoldersWithSameNames() {
        
        let targetOne = FileRule.Target.folders(name: "TestName")
        let targetTwo = FileRule.Target.folders(name: "TestName")
        XCTAssertEqual(targetOne, targetTwo)
    }
    
    func testFileRuleTargetsAreNotEqualWhenTargetIsFoldersWithDifferentNames() {
        
        let targetOne = FileRule.Target.folders(name: "aName")
        let targetTwo = FileRule.Target.folders(name: "aDifferentName")
        XCTAssertNotEqual(targetOne, targetTwo)
    }
    
    func testFileRuleTargetsAreEqualWhenTargetIsFilesWithMatchingNamesAndExtensions() {
        
        let targetOne = FileRule.Target.files(name: "TestName", ext: "TestExtension")
        let targetTwo = FileRule.Target.files(name: "TestName", ext: "TestExtension")
        XCTAssertEqual(targetOne, targetTwo)
    }
    
    func testFileRuleTargetsAreNotEqualWhenTargetIsFilesWithMatchingNamesButDifferentExtensions() {
        
        let targetOne = FileRule.Target.files(name: "TestName", ext: "anExtension")
        let targetTwo = FileRule.Target.files(name: "TestName", ext: "aDifferentExtension")
        XCTAssertNotEqual(targetOne, targetTwo)
    }
    
    func testFileRuleTargetsAreNotEqualWhenTargetIsFilesWithDifferentNamesButSameExtensions() {
        
        let targetOne = FileRule.Target.files(name: "aName", ext: "TestExtension")
        let targetTwo = FileRule.Target.files(name: "aDifferentName", ext: "TestExtension")
        XCTAssertNotEqual(targetOne, targetTwo)
    }
    
    // MARK: - Test FileRule Equatable
    
    func testFileRulesAreEqualWhenTargetsAndFiltersAreTheSame() {
        
        let ruleOne = FileRule(target: .folders(name: "FolderName"), filter: .include)
        let ruleTwo = FileRule(target: .folders(name: "FolderName"), filter: .include)
        XCTAssertEqual(ruleOne, ruleTwo)
    }
    
    func testFileRulesAreNotEqualWithSameTargetsButDifferentFilters() {
        
        let ruleOne = FileRule(target: .folders(name: "FolderName"), filter: .include)
        let ruleTwo = FileRule(target: .folders(name: "FolderName"), filter: .exclude)
        XCTAssertNotEqual(ruleOne, ruleTwo)
    }
    
    func testFileRulesAreNotEqualWithDifferentTargetsButSameFilters() {
        
        let ruleOne = FileRule(target: .folders(name: "FolderName"), filter: .include)
        let ruleTwo = FileRule(target: .folders(name: "aDifferentName"), filter: .include)
        XCTAssertNotEqual(ruleOne, ruleTwo)
    }

    // MARK: - Test FileRule.Target Dictionary Representable
    
    func testFileRuleTargetFilesWithNameToDictionaryRepresentationAndBackIsTheSame() {
        
        let target = FileRule.Target.files(name: "TestName", ext: nil)
        let dictionary = target.dictionaryRepresentation
        let fromDictionary = FileRule.Target(dictionaryRepresentation: dictionary)
        XCTAssertEqual(target, fromDictionary)
    }
    
    func testFileRuleTargetFilesWithExtensionToDictionaryRepresentationAndBackIsTheSame() {
        
        let target = FileRule.Target.files(name: nil, ext: "TestExtension")
        let dictionary = target.dictionaryRepresentation
        let fromDictionary = FileRule.Target(dictionaryRepresentation: dictionary)
        XCTAssertEqual(target, fromDictionary)
    }
    
    func testFileRuleTargetFilesWithNameAndExtensionToDictionaryRepresentationAndBackIsTheSame() {
        
        let target = FileRule.Target.files(name: "TestName", ext: "TestExtension")
        let dictionary = target.dictionaryRepresentation
        let fromDictionary = FileRule.Target(dictionaryRepresentation: dictionary)
        XCTAssertEqual(target, fromDictionary)
    }
    
    func testFileRuleTargetFoldersToDictionaryRepresentationAndBackIsTheSame() {
        
        let target = FileRule.Target.folders(name: "TestName")
        let dictionary = target.dictionaryRepresentation
        let fromDictionary = FileRule.Target(dictionaryRepresentation: dictionary)
        XCTAssertEqual(target, fromDictionary)
    }
    
    // MARK: - Test FileRule.Filter String Representable

    func testFileRuleFilterIncludeToStringAndBackIsTheSame() {
        
        let filter = FileRule.Filter.include
        let string = filter.stringRepresentation
        let fromString = FileRule.Filter(stringRepresentation: string)
        XCTAssertEqual(filter, fromString)
    }
    
    func testFileRuleFilterExcludeToStringAndBackIsTheSame() {
        
        let filter = FileRule.Filter.exclude
        let string = filter.stringRepresentation
        let fromString = FileRule.Filter(stringRepresentation: string)
        XCTAssertEqual(filter, fromString)
    }
    
    // MARK: - Test FileRule Dictionary Representable
    
    func testFileRuleToDictionaryAndBackIsTheSame() {
        
        let rule = FileRule(target: .files(name: "TestName", ext: "TestExtension"),
                            filter: .exclude)
        let dictionary = rule.dictionaryRepresentation
        let fromDictionary = FileRule(dictionaryRepresentation: dictionary)
        XCTAssertEqual(rule, fromDictionary)
    }

    // MARK: - Test File Matching
    
    func testFileRuleIncludesFilesWithMatchingNames() {
        
        let matchingFiles = [
            File(name: "hello", ext: "png", path: ""),
            File(name: "hello", ext: "wav", path: ""),
            File(name: "hello", ext: "pdf", path: "")
        ]
        
        let nonMatchingFiles = [
            File(name: "apple", ext: "png", path: ""),
            File(name: "ball", ext: "wav", path: ""),
            File(name: "cat", ext: "pdf", path: "")
        ]
        
        let rule = FileRule(target: .files(name: "hello", ext: nil),
                            filter: .include)
        
        for file in matchingFiles {
            XCTAssertTrue(rule.includes(file: file))
        }
        
        for file in nonMatchingFiles {
            XCTAssertFalse(rule.includes(file: file))
        }
    }
    
    func testFileRuleIncludesFilesWithMatchingExtensions() {
        
        let matchingFiles = [
            File(name: "apple", ext: "pdf", path: ""),
            File(name: "ball", ext: "pdf", path: ""),
            File(name: "cat", ext: "pdf", path: "")
        ]
        
        let nonMatchingFiles = [
            File(name: "apple", ext: "png", path: ""),
            File(name: "ball", ext: "wav", path: ""),
            File(name: "cat", ext: "tiff", path: "")
        ]
        
        let rule = FileRule(target: .files(name: nil, ext: "pdf"),
                            filter: .include)
        
        for file in matchingFiles {
            XCTAssertTrue(rule.includes(file: file))
        }
        
        for file in nonMatchingFiles {
            XCTAssertFalse(rule.includes(file: file))
        }
    }
    
    func testFileRuleIncludesFilesWithMatchingNamesAndExtensions() {
        
        let matchingFiles = [
            File(name: "apple", ext: "png", path: ""),
        ]
        
        let nonMatchingFiles = [
            File(name: "apple", ext: "wav", path: ""),
            File(name: "apple", ext: "pdf", path: ""),
            File(name: "Apple", ext: "png", path: ""),
            File(name: "ball", ext: "wav", path: ""),
            File(name: "cat", ext: "tiff", path: ""),
            File(name: "dog", ext: "png", path: "")
        ]
        
        let rule = FileRule(target: .files(name: "apple", ext: "png"),
                            filter: .include)
        
        for file in matchingFiles {
            XCTAssertTrue(rule.includes(file: file))
        }
        
        for file in nonMatchingFiles {
            XCTAssertFalse(rule.includes(file: file))
        }
    }
    
    func testFileRuleIncludesFoldersWithMatchingNames() {
        
        let matchingFolders = [
            Directory(name: "Apple", path: "")
        ]
        
        let nonMatchingFolders = [
            Directory(name: "apple", path: ""),
            Directory(name: "Ball", path: ""),
            Directory(name: "Cat", path: "")
        ]
        
        let rule = FileRule(target: .folders(name: "Apple"),
                            filter: .include)
        
        for folder in matchingFolders {
            XCTAssertTrue(rule.includes(directory: folder))
        }
        
        for folder in nonMatchingFolders {
            XCTAssertFalse(rule.includes(directory: folder))
        }
    }
    
    func testFileRuleExcludesFoldersWithMatchingNames() {
        
        let matchingFolders = [
            Directory(name: "Apple", path: "")
        ]
        
        let nonMatchingFolders = [
            Directory(name: "apple", path: ""),
            Directory(name: "Ball", path: ""),
            Directory(name: "Cat", path: "")
        ]
        
        let rule = FileRule(target: .folders(name: "Apple"),
                            filter: .exclude)
        
        for folder in matchingFolders {
            XCTAssertTrue(rule.excludes(directory: folder))
        }
        
        for folder in nonMatchingFolders {
            XCTAssertFalse(rule.excludes(directory: folder))
        }
    }
}
