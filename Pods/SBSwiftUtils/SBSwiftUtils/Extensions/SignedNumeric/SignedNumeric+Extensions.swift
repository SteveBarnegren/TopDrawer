//
//  SignedNumeric+Extensions.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 13/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension SignedNumeric where Self: Comparable {
    
    /// The value's absolute value
    var abs: Self {
        return Swift.abs(self)
    }
    
    /// The absolute distance to another value
    ///
    /// - Parameter other: The value to measure to
    /// - Returns: The absolute distance between `self` and `other`
    func absDistance(to other: Self) -> Self {
        return Swift.abs(self - other)
    }
}
