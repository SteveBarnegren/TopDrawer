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
    
    func testFolderRuleToDictionaryAndBackIsTheSame() {
        
        let condition1 = FolderCondition.name(.matching("birds"))
        let condition2 = FolderCondition.path(.matching("photos/birds"))
        let rule = FolderRule(conditions: [condition1, condition2])

        XCTAssertTrue(rule == rule.convertedToDictionaryAndBack)
    }
}
