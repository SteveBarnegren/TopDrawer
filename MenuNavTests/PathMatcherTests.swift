//
//  PathMatcherTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

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
    
    // MARK: - Test DictionaryRepresentable
    
    func testPathMatcherToDictionaryAndBackIsTheSame() {
        
        let matching = PathMatcher.matching("animals/Dog.png")
        let notMatching = PathMatcher.notMatching("animals/Dog.png")

        XCTAssertTrue(matching == matching.convertedToDictionaryAndBack)
        XCTAssertTrue(notMatching == notMatching.convertedToDictionaryAndBack)
    }

   
}
