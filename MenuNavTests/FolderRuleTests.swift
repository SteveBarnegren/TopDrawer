//
//  FolderRuleTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

class FolderRuleTests: XCTestCase {
    
    // MARK: - Test Matching
    
    func testMatchesDirectoryWithSingleCondition() {
        
        let folder = Directory(name: "birds", path: "animals/birds")
        let condition = FolderCondition.name(.matching("birds"))
        let rule = FolderRule(conditions: [condition])
        
        XCTAssertTrue(rule.excludes(directory: folder))
    }
    
    func testMatchesDirectoryWithMultipleConditions() {
        
        let folder = Directory(name: "birds", path: "animals/birds")
        let condition1 = FolderCondition.name(.matching("birds"))
        let condition2 = FolderCondition.path(.matching("animals/birds"))
        let rule = FolderRule(conditions: [condition1, condition2])
        
        XCTAssertTrue(rule.excludes(directory: folder))
    }
    
    func testFailsToMatchDirectoryWithMultipleConditions() {
        
        let folder = Directory(name: "birds", path: "animals/birds")
        let condition1 = FolderCondition.name(.matching("birds"))
        let condition2 = FolderCondition.path(.matching("photos/birds"))
        let rule = FolderRule(conditions: [condition1, condition2])

        XCTAssertFalse(rule.excludes(directory: folder))
    }

    // MARK: - Test Equatable
    
    func testFolderRulesWithSameConditonsAreEqual() {
        
        func makeRule() -> FolderRule {
            
            let condition1 = FolderCondition.name(.matching("birds"))
            let condition2 = FolderCondition.path(.matching("photos/birds"))
            return FolderRule(conditions: [condition1, condition2])
        }
        
        let firstRule = makeRule()
        let secondRule = makeRule()
        
        XCTAssertTrue(firstRule == secondRule)
    }
    
    func testFolderRulesWithDifferentConditionsAreNotEqual() {
        
        let firstCondition = FolderCondition.name(.matching("birds"))
        let firstRule = FolderRule(conditions: [firstCondition])
        
        let secondCondition = FolderCondition.name(.matching("reptiles"))
        let secondRule = FolderRule(conditions: [secondCondition])
        
        XCTAssertFalse(firstRule == secondRule)
    }
    
    // MARK: - Test Dictionary Represenatable
    
    // swiftlint:disable function_body_length
    func testFolderRuleToDictionaryAndBackIsTheSame() {
        
        var allConditions = [FolderCondition]()
        
        func makeCondition(_ condition: FolderCondition) -> FolderCondition {
            allConditions.append(condition)
            return condition
        }

        // Name is
        _ = {
            let condition = makeCondition(FolderCondition.name(.matching("birds")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name is not
        _ = {
            let condition = makeCondition(FolderCondition.name(.notMatching("birds")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name containing
        _ = {
            let condition = makeCondition(FolderCondition.name(.containing("birds")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Name not containing
        _ = {
            let condition = makeCondition(FolderCondition.name(.notContaining("birds")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Path is
        _ = {
            let condition = makeCondition(FolderCondition.path(.matching("birds")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Path is not
        _ = {
            let condition = makeCondition(FolderCondition.path(.notMatching("birds")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Contains files with extension
        _ = {
            let condition = makeCondition(FolderCondition.contains(.filesWithExtension("png")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Contains files with full name
        _ = {
            let condition = makeCondition(FolderCondition.contains(.filesWithFullName("report.pdf")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Contains folder with name
        _ = {
            let condition = makeCondition(FolderCondition.contains(.foldersWithName("birds")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Doesn't contain files with extension
        _ = {
            let condition = makeCondition(FolderCondition.doesntContain(.filesWithExtension("png")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Doesn't contain files with full name
        _ = {
            let condition = makeCondition(FolderCondition.doesntContain(.filesWithFullName("report.pdf")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()
        
        // Doesn't contain folders with name
        _ = {
            let condition = makeCondition(FolderCondition.doesntContain(.foldersWithName("birds")))
            let rule = FolderRule(conditions: [condition])
            XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
        }()

        // All Conditions
        if allConditions.count < 2 {
            fatalError("All conditions array is not being populated")
        }
        let allConditionsRule = FolderRule(conditions: allConditions)
        XCTAssertTrue(allConditionsRule == allConditionsRule.convertedToDictionaryAndBack)
    }
    // swiftlint:enable function_body_length
    
}
