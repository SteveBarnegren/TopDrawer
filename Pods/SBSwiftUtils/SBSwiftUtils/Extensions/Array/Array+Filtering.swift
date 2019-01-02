//
//  Array+Filtering.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 13/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Mutating version of the Swift standard library `filter()` function.
    ///
    ///     var array = [1, 2, 3, 4, 5]
    ///     array.filterInPlace { $0 % == 0 }
    ///     print("\(array)") // [2, 4]
    ///
    /// - Parameter isIncluded: Closure to determine if an element should be included in
    /// the array
    mutating func filterInPlace(isIncluded: (Element) -> Bool) {
        self = self.filter(isIncluded)
    }
    
    /// Removes elements from the array where `shouldRemove` returns `true`
    ///
    /// - Parameter shouldRemove: Closure returning `true` if an element should be
    /// removed
    mutating func remove(shouldRemove: (Element) -> Bool) {
        self = self.filter { shouldRemove($0) == false }
    }
}
