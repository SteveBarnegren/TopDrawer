//
//  Array+Extensions.swift
//  MenuNav
//
//  Created by Steve Barnegren on 25/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

extension Array {

    func appending(_ item: Element) -> [Element] {

        var copy = self
        copy.append(item)
        return copy
    }
}

extension Array where Element: Comparable {
    
    func sortedAscending() -> [Element] {
        return sorted { $0 < $1 }
    }
    
    func sortedDescending() -> [Element] {
        return sorted { $0 > $1 }
    }
    
    mutating func sortAscending() {
        sort { $0 < $1 }
    }
    
    mutating func sortDescending() {
        sort { $0 > $1 }
    }
}
