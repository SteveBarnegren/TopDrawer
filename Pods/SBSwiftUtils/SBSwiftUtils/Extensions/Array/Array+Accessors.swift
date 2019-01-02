//
//  Array+Accessors.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 11/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - Pop First

public extension Array {
    
    /// Removes and returns the first element of the array
    ///
    /// - Returns: The first element of the array, or `nil` if empty.
    mutating func popFirst() -> Element? {
        
        if self.isEmpty {
            return nil
        } else {
            return self.remove(at: 0)
        }
    }
}
