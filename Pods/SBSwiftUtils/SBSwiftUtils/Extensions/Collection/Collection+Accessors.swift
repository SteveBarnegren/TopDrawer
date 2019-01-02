//
//  Collection+Accessors.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 18/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - Maybe Subscript

public extension Collection where Index == Int {
    
    /// Subscript for accessing an item at an index, or `nil` if the index is out of
    /// bounds
    ///
    ///      if let item = array[maybe: 2] {
    ///          // ...
    ///      }
    ///
    /// - Parameter index: Index of the item to access
    subscript(maybe index: Int) -> Element? {
        
        if index > count - 1 {
            return nil
        } else if index < 0 {
            return nil
        } else {
            return self[index]
        }
    }
}

// MARK: - Throwing Accessor

public enum CollectionAccessError: Error {
    case outOfBounds
}

public extension Collection where Index == Int {
    
    /// Used to access an item at a given index in a throwing context. If the index is
    /// out of bounds, an Error is thrown rather than an exception
    ///
    /// - Parameter index: Index of the item to access
    /// - Returns: An instance of `Element`
    /// - Throws: `CollectionAccessError.outOfBounds` if the index is out of bounds
    func at(throwing index: Index) throws -> Element {
        
        if index < count {
            return self[index]
        } else {
            throw CollectionAccessError.outOfBounds
        }
    }
}
