//
//  Array+Insertion.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 11/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - Prepend

public extension Array {
    
    /// Inserts `item` at the front of the array
    ///
    /// - Parameter item: Item to insert
    mutating func prepend(_ item: Element) {
        insert(item, at: 0)
    }
    
    /// Inserts the conents of `newElements` to the front of the array
    ///
    /// - Parameter newElements: The items to insert
    mutating func prepend<C>(contentsOf newElements: C) where C: Collection, Element == C.Element {
        insert(contentsOf: newElements, at: 0)
    }
}

// MARK: - Prepending

public extension Array {
    
    /// Returns a new array with `item` inserted at index `0`
    ///
    /// - Parameter item: The item to prepend
    /// - Returns: Array of `Element`
    func prepending(_ item: Element) -> [Element] {
        var newArray = self
        newArray.insert(item, at: 0)
        return newArray
    }
    
    /// Returns a new array with the items contained in `newElements` inserted at the
    /// front
    ///
    /// - Parameter newElements: The elements to insert
    /// - Returns: Array of `Element`
    func prepending<C>(contentsOf newElements: C) -> [Element] where C: Collection, Element == C.Element {
        var newArray = self
        newArray.insert(contentsOf: newElements, at: 0)
        return newArray
    }
}

// MARK: - Appending

public extension Array {
    
    /// Returns a new array with `item` appended
    ///
    /// - Parameter item: The item to append
    /// - Returns: Array of `Element`
    func appending(_ item: Element) -> [Element] {
        var newArray = self
        newArray.append(item)
        return newArray
    }
    
    /// Returns a new array with the contents of `newElements` appended
    ///
    /// - Parameter newElements: The elements to append
    /// - Returns: Array of `Element`
    func appending<C>(contentsOf newElements: C) -> [Element] where C: Collection, Element == C.Element {
        
        if count == 0 {
            return Array(newElements)
        } else {
            var newArray = self
            newArray.insert(contentsOf: newElements, at: newArray.count)
            return newArray
        }
    }
}
