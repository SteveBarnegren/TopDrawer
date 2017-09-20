//
//  WeakArrayTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest

class WeakArrayTests: XCTestCase {
    
    class TestObject: Equatable {
    
        static func == (lhs: TestObject, rhs: TestObject) -> Bool {
            return lhs === rhs
        }
    }
    
    func testWeakArrayReturnsObjects() {
        
        let object1 = TestObject()
        let object2 = TestObject()
        
        let array = WeakArray<TestObject>()
        array.append(object1)
        array.append(object2)
        
        XCTAssertEqual([object1, object2], array.objects)
    }
    
    func testWeakArrayRemoveObject() {
        
        let object1 = TestObject()
        let object2 = TestObject()
        
        let array = WeakArray<TestObject>()
        array.append(object1)
        array.append(object2)
        array.remove(object1)
        
        XCTAssertEqual([object2], array.objects)
    }

    func testWeakArrayRemovesDeallocatedObjects() {
        
        let object1 = TestObject()
        var object2: TestObject? = TestObject()
        
        let array = WeakArray<TestObject>()
        array.append(object1)
        array.append(object2!)
        object2 = nil
        
        XCTAssertEqual([object1], array.objects)
    }
 
}
