//
//  HierarchyInformationTests.swift
//  MenuNavTests
//
//  Created by Steve Barnegren on 21/10/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest
@testable import TopDrawer

class HierarchyInformationTests: XCTestCase {

    func testHierachyInformationContainsAddedFolder() {
        
        var hierarchyInformation = HierarchyInformation()
        hierarchyInformation.add(folderName: "Hello")
        XCTAssertTrue(hierarchyInformation.containsFolder { $0 == "Hello" })
    }
    
    func testHierachyInformationDoesntContainNotAddedFolder() {
        
        let hierarchyInformation = HierarchyInformation()
        XCTAssertFalse(hierarchyInformation.containsFolder { $0 == "Hello" })
    }

}
