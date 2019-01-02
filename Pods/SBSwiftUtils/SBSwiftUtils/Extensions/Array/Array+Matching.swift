//
//  Array+Matching.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 13/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Returns `true` if `isMatching` returns `true` for every element in the array
    ///
    /// - Parameter isMatching: Closure to match elements
    /// - Returns: `true` if all elements match, or `false` if they don't
    func allMatch(isMatching: (Element) -> Bool) -> Bool {
        
        if isEmpty {
            return false
        }
        
        for item in self {
            if isMatching(item) == false {
                return false
            }
        }
        
        return true
    }
}
