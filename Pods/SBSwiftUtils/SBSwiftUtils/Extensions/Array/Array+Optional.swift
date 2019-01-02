//
//  Array+Optional.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 13/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Returns an array where `nil` values are removed, and non-nil values are returned
    /// as non-optional
    ///
    ///     let array: [Int?] = [1, 2, nil, 10, nil, 20]
    ///     let newArray = array.flattened()
    ///     print("\(newArray)") // [1, 2, 10, 20]
    ///
    /// - Returns: Array of `Element` (from `Element?`)
    func flattened<T>() -> [T] where Element == T? {
        return compactMap { $0 }
    }
}
