//
//  Array+Sorting.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 11/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - Sort Ascending / Descending

public extension Array where Element: Comparable {
    
    /// Returns a new array sorted in ascending order
    ///
    /// - Returns: Array of `Element`
    func sortedAscending() -> [Element] {
        return sorted { $0 < $1 }
    }
    
    /// Returns a new array sorted in descending order
    ///
    /// - Returns: Array of `Element`
    func sortedDescending() -> [Element] {
        return sorted { $0 > $1 }
    }
    
    /// Sorts an array of `Comparable` elements in ascending order
    mutating func sortAscending() {
        sort { $0 < $1 }
    }
    
    /// Sorts an array of `Comparable` elements in descending order
    mutating func sortDescending() {
        sort { $0 > $1 }
    }
}

// MARK: - Sort Ascending / Descending By

public extension Array {
    
    /// Returns a new array sorted ascending by the `Comparable` result of transforming
    /// each element through the `transform` closure
    ///
    ///     let array = ["parrot", "dog", "worm"]
    ///     let sortedByLength = array.sortedAscendingBy { $0.count }
    ///     print("\(sortedByLength)") // ["dog", "worm", "parrot"]
    ///
    /// - Parameter transform: Closure to transform each `Element` to a `Comparable`
    /// type
    /// - Returns: Array of `Element`
    func sortedAscendingBy<T: Comparable>(_ transform: (Element) -> T) -> [Element] {
        return sorted { transform($0) < transform($1) }
    }
    
    /// Returns a new array sorted descending by the `Comparable` result of transforming
    /// each element through the `transform` closure
    ///
    ///     let array = ["parrot", "dog", "worm"]
    ///     let sortedByLength = array.sortedDescendingBy { $0.count }
    ///     print("\(sortedByLength)") // ["parrot", "worm", "dog"]
    ///
    /// - Parameter transform: Closure to transform each `Element` to a `Comparable`
    /// type
    /// - Returns: Array of `Element`
    func sortedDescendingBy<T: Comparable>(_ transform: (Element) -> T) -> [Element] {
        return sorted { transform($0) > transform($1) }
    }
    
    /// Sorts the `Element`s in ascending order
    ///
    /// - Parameter transform: Closure to transform each element to a `Comparable` type
    mutating func sortAscendingBy<T: Comparable>(_ transform: (Element) -> T) {
        sort { transform($0) < transform($1) }
    }
    
    /// Sorts the `Element`s in descending order
    ///
    /// - Parameter transform: Closure to transform each element to a `Comparable` type
    mutating func sortDescendingBy<T: Comparable>(_ transform: (Element) -> T) {
        sort { transform($0) > transform($1) }
    }
}

// MARK: - Bring To Front / Send To Back

public extension Array {
    
    /// Brings items to the front of the array where `matches` returns true. Maintains
    /// the order of matched items.
    ///
    ///     var array = ["cow", "cat", "dog", "bat"]
    ///     array.bringToFront { $0.hasSuffix("at") }
    ///     print(array) // ["cat", "bat", "cow", "dog"]
    ///
    /// - Parameter matches: Closure to match elements
    mutating func bringToFront(_ matches: (Element) -> Bool) {
        
        var indexesToMove = [Int]()
        var itemsToMove = [Element]()
        
        // Find the items to move
        for (index, item) in self.enumerated() {
            if matches(item) {
                indexesToMove.append(index)
                itemsToMove.append(item)
            }
        }
        
        // Remove the last items first, so that the indexes are always in bounds
        for index in indexesToMove.reversed() {
            remove(at: index)
        }
        
        // Insert the items at the front
        // in the reverse order that we found them
        // so that they maintain their original order
        itemsToMove.reversed().forEach {
            insert($0, at: 0)
        }
    }
    
    /// Sends items to the back of the array where `matches` returns true. Maintains the
    /// order of matched items.
    ///
    ///     var array = ["cat", "cow", "bat", "dog"]
    ///     array.sendToBack { $0.hasSuffix("at") }
    ///     print(array) // ["cow", "dog", "cat", "bat"]
    ///
    /// - Parameter matches: Closure to match elements
    mutating func sendToBack(_ matches: (Element) -> Bool) {
        
        var indexesToMove = [Int]()
        var itemsToMove = [Element]()
        
        // Find the items to move
        for (index, item) in self.enumerated() {
            if matches(item) {
                indexesToMove.append(index)
                itemsToMove.append(item)
            }
        }
        
        // Remove the last items first, so that the indexes are always in bounds
        for index in indexesToMove.reversed() {
            remove(at: index)
        }
        
        // Insert the items at the back
        itemsToMove.forEach {
            append($0)
        }
    }
}
