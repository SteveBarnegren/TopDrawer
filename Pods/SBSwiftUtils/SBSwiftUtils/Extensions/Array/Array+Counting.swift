//
//  Array+Counting.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 13/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Returns the number of objects where `matches(element)` is `true`
    ///
    /// - Parameter matches: Closure to match elements by
    /// - Returns: The number of elements where `matches` returns `true`
    func count(where matches: (Element) -> Bool) -> Int {
        var count = 0
        for element in self where matches(element) {
            count += 1
        }
        return count
    }
    
}
