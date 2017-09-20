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
    
    // MARK: - Test Matching
    
    func testMatchesFilesWithASingleCondition() {
        
        let file = File(name: "dog", ext: "png", path: "animals/dog.png")
        
        let condtion = FileCondition.ext(.matching("png"))
        let rule = FileRule(conditions: [condtion])
        
        XCTAssertTrue(rule.includes(file: file))
    }
    
    func testMatchesFilesWithMultipleConditions() {
        
        let file = File(name: "dog", ext: "png", path: "animals/dog.png")
        
        let condtion1 = FileCondition.ext(.matching("png"))
        let condtion2 = FileCondition.name(.notContaining("cat"))

        let rule = FileRule(conditions: [condtion1, condtion2])
        
        XCTAssertTrue(rule.includes(file: file))
    }
    
    func testFailsToMatchFilesWithSingleCondition() {
        
        let file = File(name: "dog", ext: "png", path: "animals/dog.png")
        
        let condtion = FileCondition.ext(.matching("pdf"))
        
        let rule = FileRule(conditions: [condtion])
        
        XCTAssertFalse(rule.includes(file: file))
    }
    
    func testFailsToMatchFilesWithMultipleConditions() {
        
        let file = File(name: "dog", ext: "png", path: "animals/dog.png")
        
        let condtion1 = FileCondition.ext(.matching("png"))
        let condtion2 = FileCondition.name(.notContaining("dog"))
        
        let rule = FileRule(conditions: [condtion1, condtion2])
        
        XCTAssertFalse(rule.includes(file: file))
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
    
    // swiftlint:disable function_body_length
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
    // swiftlint:enable function_body_length
    
}
