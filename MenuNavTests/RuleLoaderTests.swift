//
//  RuleLoaderTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

class RuleLoaderTests: XCTestCase {
    
    func testRuleLoaderStoresAndRetrievesRules() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let ruleLoader = RuleLoader<FileRule>(keyValueStore: keyValueStore)
        
        let rules = [
            FileRule(conditions: [.name(.matching("hello"))]),
            FileRule(conditions: [.ext(.matching("png"))])
        ]
        
        ruleLoader.rules = rules
        
        XCTAssertEqual(ruleLoader.rules, rules)
    }
    
    func testRuleLoaderReportsCorrectNumberOfRules() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let ruleLoader = RuleLoader<FileRule>(keyValueStore: keyValueStore)
        
        let rules = [
            FileRule(conditions: [.name(.matching("hello"))]),
            FileRule(conditions: [.ext(.matching("png"))])
        ]
        
        ruleLoader.rules = rules
        
        XCTAssertEqual(ruleLoader.numberOfRules, 2)
    }
    
    func testRuleLoaderAddRule() {
    
        let keyValueStore = DictionaryKeyValueStore()
        let ruleLoader = RuleLoader<FileRule>(keyValueStore: keyValueStore)
        
        let rule1 = FileRule(conditions: [.name(.matching("hello"))])
        let rule2 = FileRule(conditions: [.ext(.matching("png"))])
        
        ruleLoader.add(rule: rule1)
        XCTAssertEqual(ruleLoader.rules, [rule1])
        
        ruleLoader.add(rule: rule2)
        XCTAssertEqual(ruleLoader.rules, [rule1, rule2])
    }
    
    func testRuleLoaderDeleteRule() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let ruleLoader = RuleLoader<FileRule>(keyValueStore: keyValueStore)
        
        let rule1 = FileRule(conditions: [.name(.matching("hello"))])
        let rule2 = FileRule(conditions: [.ext(.matching("png"))])
        
        ruleLoader.add(rule: rule1)
        ruleLoader.add(rule: rule2)
        ruleLoader.deleteRule(atIndex: 1)
        
        XCTAssertEqual(ruleLoader.rules, [rule1])
    }
    
    func testRuleLoaderUpdateRule() {
        
        let keyValueStore = DictionaryKeyValueStore()
        let ruleLoader = RuleLoader<FileRule>(keyValueStore: keyValueStore)
        
        let rule1 = FileRule(conditions: [.name(.matching("hello"))])
        let rule2 = FileRule(conditions: [.ext(.matching("png"))])
        let rule2Updated = FileRule(conditions: [.name(.containing("test"))])

        ruleLoader.rules = [rule1, rule2]
        ruleLoader.update(rule: rule2Updated, atIndex: 1)
        
        XCTAssertEqual(ruleLoader.rules, [rule1, rule2Updated])
    }
}
