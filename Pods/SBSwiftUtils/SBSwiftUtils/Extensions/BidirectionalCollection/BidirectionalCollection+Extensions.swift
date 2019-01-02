//
//  BidirectionalCollection+Extensions.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 11/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

extension BidirectionalCollection {
    
    /// Converts `BidirectionalCollection` to Array
    ///
    /// - Returns: `Array` of the elements contained in the `BidirectionalCollection`
    func toArray() -> [Element] {
        return Array(self)
    }
}
