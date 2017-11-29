//
//  FolderConditionTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest
@testable import TopDrawer

class FolderConditionTests: XCTestCase {

    // MARK: - Test Matching
    
    func testMatchesPath() {
        
        let matching = Directory(name: "birds", path: "root/animals/birds")
        let notMatching = Directory(name: "birds", path: "root/photos/birds")
        
        let condition = FolderCondition.path(.matching("root/animals/birds"))
        
        XCTAssertTrue(condition.matches(directory: matching))
        XCTAssertFalse(condition.matches(directory: notMatching))
    }
    
    func testMatchesName() {
        
        let matching = Directory(name: "birds", path: "root/animals/birds")
        let notMatching = Directory(name: "reptiles", path: "root/animals/reptiles")
        
        let condition = FolderCondition.name(.matching("birds"))
        
        XCTAssertTrue(condition.matches(directory: matching))
        XCTAssertFalse(condition.matches(directory: notMatching))
    }
    
    func testMatchesContains() {
        
        let matching = TestDirectoryBuilder.makeDirectory(withFileNames: ["dog.png"])
        let notMatching = TestDirectoryBuilder.makeDirectory(withFileNames: ["cat.gif"])
        
        let condition = FolderCondition.contains(.filesWithExtension("png"))
        
        XCTAssertTrue(condition.matches(directory: matching))
        XCTAssertFalse(condition.matches(directory: notMatching))
    }
    
    func testMatchesDoesntContain() {
        
        let notMatching = TestDirectoryBuilder.makeDirectory(withFileNames: ["dog.png"])
        let matching = TestDirectoryBuilder.makeDirectory(withFileNames: ["cat.gif"])
        
        let condition = FolderCondition.doesntContain(.filesWithExtension("png"))
        
        XCTAssertTrue(condition.matches(directory: matching))
        XCTAssertFalse(condition.matches(directory: notMatching))
    }

    // MARK: - Test Equatable
    
    func testFolderConditionsAreEqualWithEqualPath() {
        
        let firstCondtion = FolderCondition.path(.matching("animals/birds"))
        let same = FolderCondition.path(.matching("animals/birds"))
        let different = FolderCondition.path(.matching("animals/reptiles"))

        XCTAssertTrue(firstCondtion == same)
        XCTAssertFalse(firstCondtion == different)
    }
    
    func testFolderConditionsAreEqualWithEqualName() {
        
        let firstCondtion = FolderCondition.name(.matching("birds"))
        let same = FolderCondition.name(.matching("birds"))
        let different = FolderCondition.name(.matching("reptiles"))
        
        XCTAssertTrue(firstCondtion == same)
        XCTAssertFalse(firstCondtion == different)
    }
    
    func testFolderConditionsAreEqualWithEqualContains() {
        
        let firstCondtion = FolderCondition.contains(.filesWithExtension("png"))
        let same = FolderCondition.contains(.filesWithExtension("png"))
        let different = FolderCondition.contains(.filesWithExtension("gif"))
        
        XCTAssertTrue(firstCondtion == same)
        XCTAssertFalse(firstCondtion == different)
    }
    
    func testFolderConditionsAreEqualWithEqualDoesntContain() {
        
        let firstCondtion = FolderCondition.doesntContain(.filesWithExtension("png"))
        let same = FolderCondition.doesntContain(.filesWithExtension("png"))
        let different = FolderCondition.doesntContain(.filesWithExtension("gif"))
        
        XCTAssertTrue(firstCondtion == same)
        XCTAssertFalse(firstCondtion == different)
    }
    
    func testFolderConditionsAreNotEqualWithDifferentCases() {
        
        let path = FolderCondition.path(.matching("animals/birds"))
        let name = FolderCondition.name(.matching("birds"))
        let contains = FolderCondition.contains(.filesWithExtension("png"))
        let doesntContain = FolderCondition.doesntContain(.filesWithExtension("gif"))
        
        XCTAssertFalse(path == name)
        XCTAssertFalse(path == contains)
        XCTAssertFalse(path == doesntContain)
        XCTAssertFalse(name == contains)
        XCTAssertFalse(name == doesntContain)
        XCTAssertFalse(contains == doesntContain)
    }
    
    // MARK: - Test Decision Tree Element
    
    func testFolderConditionDecisionTreeElementForPath() {
        
        let condition = FolderCondition.path(.matching("animals/birds"))
        XCTAssertEqual(condition.decisionTreeInput(), "animals/birds")
    }
    
    func testFolderConditionDecisionTreeElementForName() {
        
        let condition = FolderCondition.name(.matching("birds"))
        XCTAssertEqual(condition.decisionTreeInput(), "birds")
    }
    
    func testFolderConditionDecisionTreeElementForContains() {
        
        let condition = FolderCondition.contains(.filesWithExtension("png"))
        XCTAssertEqual(condition.decisionTreeInput(), "png")
    }
    
    func testFolderConditionDecisionTreeElementForDoesntContain() {
        
        let condition = FolderCondition.doesntContain(.filesWithExtension("png"))
        XCTAssertEqual(condition.decisionTreeInput(), "png")
    }
    
    // MARK: - Test Dictionary Representable
    
    func testFolderConditionToDictionaryAndBackIsTheSame() {
        
        let path = FolderCondition.path(.matching("animals/birds"))
        let name = FolderCondition.name(.matching("birds"))
        let contains = FolderCondition.contains(.filesWithExtension("png"))
        let doesntContain = FolderCondition.doesntContain(.filesWithExtension("png"))
        
        XCTAssertTrue(path == path.convertedToDictionaryAndBack)
        XCTAssertTrue(name == name.convertedToDictionaryAndBack)
        XCTAssertTrue(contains == contains.convertedToDictionaryAndBack)
        XCTAssertTrue(doesntContain == doesntContain.convertedToDictionaryAndBack)
    }

}
