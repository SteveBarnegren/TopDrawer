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
        
        func makeRule() -> FileRule {
            
            let condtion1 = FileCondition.ext(.matching("png"))
            let condtion2 = FileCondition.name(.notContaining("dog"))
            return FileRule(conditions: [condtion1, condtion2])
        }
        
        let firstRule = makeRule()
        let secondRule = makeRule()
        
        XCTAssertTrue(firstRule == secondRule)
    }
    
    // MARK: - Test Dictionary Representable
    
    func testFileRuleToDictionaryAndBackAreTheSame() {
        
        var allConditions = [FileCondition]()
        
        func makeCondition(_ condition: FileCondition) -> FileCondition {
            allConditions.append(condition)
            return condition
        }
        
        // Name is
        let _ = {
            let condition = makeCondition(FileCondition.name(.matching("dog")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name is not
        let _ = {
            let condition = makeCondition(FileCondition.name(.notMatching("dog")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name contains
        let _ = {
            let condition = makeCondition(FileCondition.name(.containing("dog")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name does not contain
        let _ = {
            let condition = makeCondition(FileCondition.name(.notContaining("dog")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Extension is
        let _ = {
            let condition = makeCondition(FileCondition.ext(.matching("png")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Extension is not
        let _ = {
            let condition = makeCondition(FileCondition.ext(.notMatching("png")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Full name is
        let _ = {
            let condition = makeCondition(FileCondition.fullName(.matching("report.pdf")))
            let rule = FileRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Full name is not
        let _ = {
            let condition = makeCondition(FileCondition.fullName(.notMatching("report.pdf")))
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
    
}
