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
    
    func testFileRuleTargetsAreEqualWhenMatchingNames() {
        
        let target = FileRule.Target.matchingName("same")
        let same = FileRule.Target.matchingName("same")
        let different = FileRule.Target.matchingName("different")
        
        XCTAssertEqual(target, same)
        XCTAssertNotEqual(target, different)
    }
    
    func testFileRuleTargetsAreEqualWhenMatchingExtensions() {
        
        let target = FileRule.Target.matchingExtension("same")
        let same = FileRule.Target.matchingExtension("same")
        let different = FileRule.Target.matchingExtension("different")
        
        XCTAssertEqual(target, same)
        XCTAssertNotEqual(target, different)
    }
    
    func testFileRuleTargetsAreEqualWhenMatchingNamesAndExtensions() {
        
        let target = FileRule.Target.matchingNameAndExtension(name: "same", ext: "same")
        let same = FileRule.Target.matchingNameAndExtension(name: "same", ext: "same")
        let differentName = FileRule.Target.matchingNameAndExtension(name: "different", ext: "same")
        let differentExtension = FileRule.Target.matchingNameAndExtension(name: "same", ext: "different")
        
        XCTAssertEqual(target, same)
        XCTAssertNotEqual(target, differentName)
        XCTAssertNotEqual(target, differentExtension)
    }
    
    func testFileRuleTargetsAreNotEqualWhenDifferentCases() {
        
        let name = FileRule.Target.matchingName("same")
        let ext = FileRule.Target.matchingExtension("same")
        let nameAndExt = FileRule.Target.matchingNameAndExtension(name: "same", ext: "same")
        
        XCTAssertNotEqual(name, ext)
        XCTAssertNotEqual(name, nameAndExt)
    }

    // MARK: - Test FileRule Equatable
    
    func testFileRulesAreEqualWhenTargetsAndFiltersAreTheSame() {
        
        let ruleOne = FileRule(target: .matchingName("name"), filter: .include)
        let ruleTwo = FileRule(target: .matchingName("name"), filter: .include)
        XCTAssertEqual(ruleOne, ruleTwo)
    }
    
    func testFileRulesAreNotEqualWithSameTargetsButDifferentFilters() {
        
        let ruleOne = FileRule(target: .matchingName("name"), filter: .include)
        let ruleTwo = FileRule(target: .matchingName("name"), filter: .exclude)
        XCTAssertNotEqual(ruleOne, ruleTwo)
    }
    
    func testFileRulesAreNotEqualWithDifferentTargetsButSameFilters() {
        
        let ruleOne = FileRule(target: .matchingName("name"), filter: .include)
        let ruleTwo = FileRule(target: .matchingName("different"), filter: .include)
        XCTAssertNotEqual(ruleOne, ruleTwo)
    }

    // MARK: - Test FileRule.Target Dictionary Representable
    
    func testFileRuleTargetFilesWithNameToDictionaryRepresentationAndBackIsTheSame() {
        
        let target = FileRule.Target.matchingName("name")
        let dictionary = target.dictionaryRepresentation
        let fromDictionary = FileRule.Target(dictionaryRepresentation: dictionary)
        XCTAssertEqual(target, fromDictionary)
    }
    
    func testFileRuleTargetFilesWithExtensionToDictionaryRepresentationAndBackIsTheSame() {
        
        let target = FileRule.Target.matchingNameAndExtension(name: "name", ext: "ext")
        let dictionary = target.dictionaryRepresentation
        let fromDictionary = FileRule.Target(dictionaryRepresentation: dictionary)
        XCTAssertEqual(target, fromDictionary)
    }
    
    func testFileRuleTargetFilesWithNameAndExtensionToDictionaryRepresentationAndBackIsTheSame() {
        
        let target = FileRule.Target.matchingNameAndExtension(name: "name", ext: "ext")
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
        
        let rule = FileRule(target: .matchingNameAndExtension(name: "name", ext: "ext"),
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
        
        let rule = FileRule(target: .matchingName("hello"),
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
        
        let rule = FileRule(target: .matchingExtension("pdf"),
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
        
        let rule = FileRule(target: .matchingNameAndExtension(name: "apple", ext: "png"),
                            filter: .include)
        
        for file in matchingFiles {
            XCTAssertTrue(rule.includes(file: file))
        }
        
        for file in nonMatchingFiles {
            XCTAssertFalse(rule.includes(file: file))
        }
    }
}
