//
//  FileRuleTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 29/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

// swiftlint:disable function_body_length

import XCTest
@testable import TopDrawer

class FileRuleTests: XCTestCase {
    
    // MARK: - Test number of conditions
    
    func testFileRuleReportsCorrectNumberOfConditions() {
        
        let conditions = [
            FileCondition.ext(.matching("png")),
            FileCondition.ext(.matching("png")),
            FileCondition.ext(.matching("png"))
        ]
        
        let rule = FileRule(conditions: conditions)
        XCTAssertEqual(rule.numberOfConditions, 3)
    }
    
    // MARK: - Test Matching
    
    func testMatchesFilesWithASingleCondition() {
        
        let file = File(name: "dog", ext: "png", path: "animals/dog.png")
        
        let condition = FileCondition.ext(.matching("png"))
        let rule = FileRule(conditions: [condition])
        
        XCTAssertTrue(rule.includes(file: file, inHierarchy: HierarchyInformation()))
    }
    
    func testMatchesFilesWithMultipleConditions() {
        
        let file = File(name: "dog", ext: "png", path: "animals/dog.png")
        
        let condition1 = FileCondition.ext(.matching("png"))
        let condition2 = FileCondition.name(.notContaining("cat"))

        let rule = FileRule(conditions: [condition1, condition2])
        
        XCTAssertTrue(rule.includes(file: file, inHierarchy: HierarchyInformation()))
    }
    
    func testFailsToMatchFilesWithSingleCondition() {
        
        let file = File(name: "dog", ext: "png", path: "animals/dog.png")
        
        let condition = FileCondition.ext(.matching("pdf"))
        
        let rule = FileRule(conditions: [condition])
        
        XCTAssertFalse(rule.includes(file: file, inHierarchy: HierarchyInformation()))
    }
    
    func testFailsToMatchFilesWithMultipleConditions() {
        
        let file = File(name: "dog", ext: "png", path: "animals/dog.png")
        
        let condition1 = FileCondition.ext(.matching("png"))
        let condition2 = FileCondition.name(.notContaining("dog"))
        
        let rule = FileRule(conditions: [condition1, condition2])
        
        XCTAssertFalse(rule.includes(file: file, inHierarchy: HierarchyInformation()))
    }
    
    // MARK: - Test Equatable
    
    func testFileRulesWithSameConditionsAreEqual() {
        
        var condition: FileCondition?
        
        func makeRule() -> FileRule {
            return FileRule(conditions: [condition!])
        }
        
        // Name is
        _ = {
           condition = FileCondition.name(.matching("dog"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Name is not
        _ = {
            condition = FileCondition.name(.notMatching("dog"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Name contains
        _ = {
            condition = FileCondition.name(.containing("dog"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Name doesnt contain
        _ = {
            condition = FileCondition.name(.notContaining("dog"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Extension is
        _ = {
            condition = FileCondition.ext(.matching("png"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Extension is not
        _ = {
            condition = FileCondition.ext(.notMatching("png"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Full name is
        _ = {
            condition = FileCondition.fullName(.matching("Report.pdf"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Full name is not
        _ = {
            condition = FileCondition.fullName(.notMatching("Report.pdf"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Parent contains files with extension
        _ = {
            condition = FileCondition.parentContains(.filesWithExtension("png"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Parent contains files with full name
        _ = {
            condition = FileCondition.parentContains(.filesWithFullName("report.pdf"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Parent doesn't contain files with extension
        _ = {
            condition = FileCondition.parentDoesntContain(.filesWithExtension("png"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
        
        // Parent doesnt' contain files with full name
        _ = {
            condition = FileCondition.parentDoesntContain(.filesWithFullName("report.pdf"))
            XCTAssertTrue(makeRule() == makeRule())
        }()
    }
    
    // MARK: - Test Dictionary Representable
    
    func testFileRuleToDictionaryAndBackAreTheSame() {
        
        var allConditions = [FileCondition]()
        
        func makeCondition(_ condition: FileCondition) -> FileCondition {
            allConditions.append(condition)
            return condition
        }
        
        // Name is
        _ = {
            let condition = makeCondition(FileCondition.name(.matching("dog")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name is not
        _ = {
            let condition = makeCondition(FileCondition.name(.notMatching("dog")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name contains
        _ = {
            let condition = makeCondition(FileCondition.name(.containing("dog")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name does not contain
        _ = {
            let condition = makeCondition(FileCondition.name(.notContaining("dog")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Extension is
        _ = {
            let condition = makeCondition(FileCondition.ext(.matching("png")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Extension is not
        _ = {
            let condition = makeCondition(FileCondition.ext(.notMatching("png")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Full name is
        _ = {
            let condition = makeCondition(FileCondition.fullName(.matching("report.pdf")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Full name is not
        _ = {
            let condition = makeCondition(FileCondition.fullName(.notMatching("report.pdf")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Parent Contains files with extension
        _ = {
            let condition = makeCondition(FileCondition.parentContains(.filesWithExtension("png")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Parent Contains files with full name
        _ = {
            let condition = makeCondition(FileCondition.parentContains(.filesWithFullName("report.pdf")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Parent doesn't contain files with extension
        _ = {
            let condition = makeCondition(FileCondition.parentDoesntContain(.filesWithExtension("png")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Parent doesn't contain files with full name
        _ = {
            let condition = makeCondition(FileCondition.parentDoesntContain(.filesWithFullName("report.pdf")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()

        // All conditions
        if allConditions.count < 2 {
            fatalError("All conditions is not being popuplated")
        }
        
        let allConditionsRule = FileRule(conditions: allConditions)
        XCTAssertTrue(allConditionsRule == allConditionsRule.convertedToDictionaryAndBack)
    }
    
    func testDictionaryRepresentableWithNoConditionsFieldCreatesNilInstance() {
        
        let dictionary: [String: Any] = [:]
        let fileRule = FileRule(dictionaryRepresentation: dictionary)
        XCTAssertNil(fileRule)
    }
    
    func testDictionaryRepresentableWithEmptyConditionsArrayCreatesNilInstance() {
        
        // Get dictionary from FileRule
        let condition = FileCondition.name(.matching("dog"))
        let rule = FileRule(conditions: [condition])
        var dictionary = rule.dictionaryRepresentation
        
        // Remove conditions
        let conditionsKey = "Conditions"
        XCTAssertNotNil(dictionary[conditionsKey], "Expected conditions, conditions key may be incorrect")
        dictionary[conditionsKey] = []
        
        // Make a new rule (should be nil)
        let fileRule = FileRule(dictionaryRepresentation: dictionary)
        XCTAssertNil(fileRule)
    }
}
