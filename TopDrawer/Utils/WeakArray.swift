//
//  WeakArray.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

class WeakArray<T> {
    
    // MARK: - Types
    
    private struct Wrapper {
        
        weak var object: AnyObject?
        
        init(object: T) {
            self.object = object as AnyObject
        }
    }
    
    // MARK: - Properties
    
    private var array = [Wrapper]()
    
    // MARK: - Add / Remove Objects
    
    func append(_ object: T) {
        let wrapped = Wrapper(object: object)
        array.append(wrapped)
    }
    
    func remove(_ object: T) {
        
        array = array.filter { $0.object !== object as AnyObject }
    }
    
    // MARK: - Remove Deallocated Objects
    
    func removeDeallocatedObjects() {
        array = array.filter { $0.object != nil }
    }
    
    // MARK: - Retrive All Objects
    
    var objects: [T] {
        removeDeallocatedObjects()
        return array.compactMap { $0.object as? T }
    }
}
