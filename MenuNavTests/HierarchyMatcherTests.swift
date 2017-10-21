//
//  HierarchyMatcherTests.swift
//  MenuNavTests
//
//  Created by Steve Barnegren on 21/10/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest
@testable import MenuNav

class HierarchyMatcherTests: XCTestCase {
    
    // MARK: - Test Input String
    
    func testHierarchyMatcherInputString() {
        
        let matcher = HierarcyMatcher.folderWithName(.matching("Input"))
        XCTAssertEqual(matcher.inputString, "Input")        
    }
    
    // MARK: - Test Equality
    
    func testHierarchyMatcherEquality() {
        
        let matcher = HierarcyMatcher.folderWithName(.matching("Test"))
        let same = HierarcyMatcher.folderWithName(.matching("Test"))
        let different = HierarcyMatcher.folderWithName(.matching("Different"))
        
        XCTAssertEqual(matcher, same)
        XCTAssertNotEqual(matcher, different)
    }
    
    // MARK: - Test Matching

    func testHierarchyMatcherMatchesFolderWithName() {
        
        var hierarchy = HierarchyInformation()
        hierarchy.add(folderName: "Match Me")
        
        let matchingMatcher = HierarcyMatcher.folderWithName(.matching("Match Me"))
        XCTAssertTrue(matchingMatcher.matches(hierarchy: hierarchy))
        
        let notMatchingMatcher = HierarcyMatcher.folderWithName(.matching("Not Matching"))
        XCTAssertFalse(notMatchingMatcher.matches(hierarchy: hierarchy))
    }
    
    // MARK: - Test DictionaryRepresentable
    
    func testHierarchyMatcherToDictionaryAndBackisTheSame() {
        
        let matcher = HierarcyMatcher.folderWithName(.matching("Photos"))
        XCTAssertEqual(matcher, matcher.convertedToDictionaryAndBack)
    }
    
    func testHierarchyMatcherCreatedWithIncorrectDictionaryIsNil() {
        
        let dictionary = ["not": "correct"]
        XCTAssertNil(HierarcyMatcher(dictionaryRepresentation: dictionary))
    }
}
