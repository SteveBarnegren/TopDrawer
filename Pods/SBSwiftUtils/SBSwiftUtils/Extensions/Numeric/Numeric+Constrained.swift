//
//  Numeric+Constrained.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 13/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Numeric where Self: Comparable {
    
    /// Returns the value, constrained to a minimum
    ///
    /// - Parameter minimumValue: The minimum value to be returned
    /// - Returns: self or `minimumValue`, whichever is highest
    func constrained(min minimumValue: Self) -> Self {
        return Swift.max(self, minimumValue)
    }
    
    /// Returns the value, constrained to a maximum
    ///
    /// - Parameter maximumValue: The maximum value to be returned
    /// - Returns: self or `maximumValue`, whichever is lowest
    func constrained(max maximumValue: Self) -> Self {
        return Swift.min(self, maximumValue)
    }
    
    /// Returns the value, constrained between a minimum and maximum
    ///
    /// - Parameters:
    ///   - minimumValue: The minimum value to be returned
    ///   - maximumValue: The maximum value to be returned
    /// - Returns: self, constrained between min and max
    func constrained(min minimumValue: Self, max maximumValue: Self) -> Self {
        return  Swift.max(Swift.min(self, maximumValue), minimumValue)
    }
}
