//
//  PathMatcherTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest
@testable import MenuNav

class PathMatcherTests: XCTestCase {
    
    // MARK: - Test Matching
    
    func testPathMatcherMatchingCase() {
        
        let matcher = PathMatcher.matching("animals/dog.png")
        
        XCTAssertTrue(matcher.matches(string: "animals/dog.png"))
        XCTAssertFalse(matcher.matches(string: "animals/Dog.png"))
        XCTAssertFalse(matcher.matches(string: "animals/cat.png"))
        XCTAssertFalse(matcher.matches(string: "dog.png"))
    }
    
    func testPathMatcherNotMatchingCase() {
        
        let matcher = PathMatcher.notMatching("animals/dog.png")
        
        XCTAssertFalse(matcher.matches(string: "animals/dog.png"))
        XCTAssertTrue(matcher.matches(string: "animals/Dog.png"))
        XCTAssertTrue(matcher.matches(string: "animals/cat.png"))
        XCTAssertTrue(matcher.matches(string: "dog.png"))
    }
    
    // MARK: - Test Equatable
    
    func testPathMathersAreEqualWithMatchingCaseAndSameString() {
        
        let firstMatcher = PathMatcher.matching("animals/Dog.png")
        let secondMatcher = PathMatcher.matching("animals/Dog.png")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testPathMathersAreNotEqualWithMatchingCaseAndDifferentString() {
        
        let firstMatcher = PathMatcher.matching("animals/Dog.png")
        let secondMatcher = PathMatcher.matching("animals/Cat.png")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    func testPathMathersAreEqualWithNotMatchingCaseAndSameString() {
        
        let firstMatcher = PathMatcher.notMatching("animals/Dog.png")
        let secondMatcher = PathMatcher.notMatching("animals/Dog.png")
        
        XCTAssertTrue(firstMatcher == secondMatcher)
    }
    
    func testPathMathersAreNotEqualWithNotMatchingCaseAndDifferentString() {
        
        let firstMatcher = PathMatcher.notMatching("animals/Dog.png")
        let secondMatcher = PathMatcher.notMatching("animals/Cat.png")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    func testPathMatchersAreNotEqualWithMatchingAndNotMatchingCases() {
        
        let firstMatcher = PathMatcher.matching("animals/Dog.png")
        let secondMatcher = PathMatcher.notMatching("animals/Dog.png")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    func testPathMatchersAreNotEqualWithNotMatchingAndMatchingCases() {
        
        let firstMatcher = PathMatcher.notMatching("animals/Dog.png")
        let secondMatcher = PathMatcher.matching("animals/Dog.png")
        
        XCTAssertFalse(firstMatcher == secondMatcher)
    }
    
    // MARK: - Descision Tree Input Strings
    
    func testPathMatcherInputStrings() {
        
        let matchersAndOutputs: [(PathMatcher, String)] = [
            (.matching("a/a.a"), "a/a.a"),
            (.notMatching("b/b.b"), "b/b.b")
        ]
        
        for (matcher, expectedOutput) in matchersAndOutputs {
            XCTAssertEqual(matcher.inputString, expectedOutput)
        }
    }
    
    // MARK: - Test DictionaryRepresentable
    
    func testPathMatchersToDictionaryAndBackAreTheSame() {
        
        let matching = PathMatcher.matching("animals/Dog.png")
        XCTAssertTrue(matching == matching.convertedToDictionaryAndBack)
        
        let notMatching = PathMatcher.notMatching("animals/Dog.png")
        XCTAssertTrue(notMatching == notMatching.convertedToDictionaryAndBack)
    }
    
    func testPathMatcherFromDictionaryWithMissingCaseTypeFieldCreatesNilInstance() {
        
        // Get dictionary from PathMatcher
        let matching = PathMatcher.matching("animals/Dog.png")
        var dictionary = matching.dictionaryRepresentation
        
        // Remove the case key
        let caseTypeKey = "Case Key"
        XCTAssertNotNil(dictionary[caseTypeKey], "Expected dictionary to have case type, key may be incorrect")
        dictionary[caseTypeKey] = nil

        // Should be nil
        XCTAssertNil( PathMatcher(dictionaryRepresentation: dictionary) )
    }
    
    func testPathMatcherFromDictionaryWithUnknownCaseTypeFieldCreatesNilInstance() {
        
        // Get dictionary from PathMatcher
        let matching = PathMatcher.matching("animals/Dog.png")
        var dictionary = matching.dictionaryRepresentation
        
        // Replace the case key with an unknown one
        let caseTypeKey = "Case Key"
        XCTAssertNotNil(dictionary[caseTypeKey], "Expected dictionary to have case type, key may be incorrect")
        dictionary[caseTypeKey] = "Not a real case"
        
        // Should be nil
        XCTAssertNil( PathMatcher(dictionaryRepresentation: dictionary) )
    }

}
