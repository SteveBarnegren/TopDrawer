//
//  StringMatcherTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

class StringMatcherTests: XCTestCase {

    // MARK: - Test Matching
    
    func testStringMatcherMatchingCase() {
        
        let matcher = StringMatcher.matching("Dog")
        
        XCTAssertTrue(matcher.matches(string: "Dog"))
        XCTAssertFalse(matcher.matches(string: "dog"))
        XCTAssertFalse(matcher.matches(string: "cat"))
    }
    
    func testStringMatcherNotMatchingCase() {
        
        let matcher = StringMatcher.notMatching("Dog")
        
        XCTAssertFalse(matcher.matches(string: "Dog"))
        XCTAssertTrue(matcher.matches(string: "dog"))
        XCTAssertTrue(matcher.matches(string: "cat"))
    }
    
    func testStringMatcherContainingCase() {
        
        let matcher = StringMatcher.containing("Dog")
        
        XCTAssertTrue(matcher.matches(string: "Dog"))
        XCTAssertTrue(matcher.matches(string: "A Big Dog"))
        XCTAssertTrue(matcher.matches(string: "Dogs like walks"))
        
        XCTAssertFalse(matcher.matches(string: "dog"))
        XCTAssertFalse(matcher.matches(string: "Cat"))
        XCTAssertFalse(matcher.matches(string: "Cats like milk"))
    }
    
    func testStringMatcherNotContainingCase() {
        
        let matcher = StringMatcher.notContaining("Dog")
        
        XCTAssertFalse(matcher.matches(string: "Dog"))
        XCTAssertFalse(matcher.matches(string: "A Big Dog"))
        XCTAssertFalse(matcher.matches(string: "Dogs like walks"))
        
        XCTAssertTrue(matcher.matches(string: "dog"))
        XCTAssertTrue(matcher.matches(string: "Cat"))
        XCTAssertTrue(matcher.matches(string: "Cats like milk"))
    }
    
    // MARK: - Test Equatable
    
    func testStringMatchersAreEqualWithCaseMatchingAndSameString() {
        
        let firstMatcher = StringMatcher.matching("Dog")
        let secondMatcher = StringMatcher.matching("Dog")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testStringMatchersAreNotEqualWithCaseMatchingAndDifferentString() {
        
        let firstMatcher = StringMatcher.matching("Dog")
        let secondMatcher = StringMatcher.matching("Cat")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    func testStringMatchersAreEqualWithCaseNotMatchingAndSameString() {
        
        let firstMatcher = StringMatcher.notMatching("Dog")
        let secondMatcher = StringMatcher.notMatching("Dog")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testStringMatchersAreNotEqualWithCaseNotMatchingAndDifferentString() {
        
        let firstMatcher = StringMatcher.notMatching("Dog")
        let secondMatcher = StringMatcher.notMatching("Cat")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    func testStringMatchersAreEqualWithCaseContainingAndSameString() {
        
        let firstMatcher = StringMatcher.containing("Dog")
        let secondMatcher = StringMatcher.containing("Dog")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testStringMatchersAreNotEqualWithCaseContainingAndDifferentString() {
        
        let firstMatcher = StringMatcher.containing("Dog")
        let secondMatcher = StringMatcher.containing("Cat")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    func testStringMatchersAreEqualWithCaseNotContainingAndSameString() {
        
        let firstMatcher = StringMatcher.notContaining("Dog")
        let secondMatcher = StringMatcher.notContaining("Dog")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testStringMatchersAreNotEqualWithCaseNotContainingAndDifferentString() {
        
        let firstMatcher = StringMatcher.notContaining("Dog")
        let secondMatcher = StringMatcher.notContaining("Cat")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    func testStringMatchersAreNotEqualWithDifferentCases() {
        
        let matching = StringMatcher.matching("Dog")
        let notMatching = StringMatcher.notMatching("Dog")
        let containing = StringMatcher.containing("Dog")
        let notContaining = StringMatcher.notContaining("Dog")
        
        XCTAssertFalse(matching == notMatching)
        XCTAssertFalse(matching == containing)
        XCTAssertFalse(matching == notContaining)
    }

    // MARK: - Test DictionaryRepresentable
    
    func testStringMatcherToDictionaryAndBackisEqual() {
        
        let matching = StringMatcher.matching("Dog")
        let notMatching = StringMatcher.notMatching("Dog")
        let containing = StringMatcher.containing("Dog")
        let notContaining = StringMatcher.notContaining("Dog")
        
        XCTAssertTrue(matching == matching.convertedToDictionaryAndBack)
        XCTAssertTrue(notMatching == notMatching.convertedToDictionaryAndBack)
        XCTAssertTrue(containing == containing.convertedToDictionaryAndBack)
        XCTAssertTrue(notContaining == notContaining.convertedToDictionaryAndBack)
    }
   
}
