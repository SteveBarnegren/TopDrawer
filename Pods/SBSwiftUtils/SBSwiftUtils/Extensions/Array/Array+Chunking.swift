//
//  Array+Chunking.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 11/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - Chunked By Size

public extension Array {
    
    /// Returns `[[Element]]` where the number of items in each inner array is equal to
    /// `size`. The last array may have fewer items than `size` if `count % size != 0`
    ///
    /// - Parameter size: The number of items in each inner array
    /// - Returns: Array of `[Element]`
    func chunked(size: Int) -> [[Element]] {
        
        return stride(from: 0, to: self.count, by: size).map {
            let chunkStart = $0
            let chunkEnd = Swift.min($0 + size, self.count)
            return self[chunkStart..<chunkEnd].toArray()
        }
    }
}

// MARK: - Chunked At Change To

public extension Array {
    
    /// Returns `[[Element]]` where each new inner array begins when the result of
    /// `key(element)` changes
    ///
    ///     [4, 4, 9, 2, 2, 2, 7, 7].chunked(atChangeTo: { $0 })
    ///     // [[4, 4], [9], [2, 2, 2], [7, 7]]
    ///
    /// - Parameter key: Closure to transform `Element` to `Equatable`
    /// - Returns: Array of `[Element]`
    func chunked<T: Equatable>(atChangeTo key: (Element) -> T) -> [[Element]] {
        
        var groups = [[Element]]()
        
        func addGroup(_ groupToAdd: [Element]) {
            if groupToAdd.isEmpty == false {
                groups.append(groupToAdd)
            }
        }
        
        var lastKey: T?
        var currentGroup = [Element]()
        
        for item in self {
            let itemKey = key(item)
            if itemKey == lastKey {
                currentGroup.append(item)
            } else {
                addGroup(currentGroup)
                currentGroup.removeAll()
                currentGroup.append(item)
            }
            lastKey = itemKey
        }
        
        addGroup(currentGroup)
        return groups
    }
}

// MARK: - Chunked At

public extension Array {
    
    /// Returns `[[Element]]` where each new inner array begins when the result of
    /// `shouldStartNewChunk(element)` returns `true`
    ///
    ///     [1, 2, 1, 2, 3, 1, 2].chunked(at: { $0 == 1 })
    ///     // [[1, 2], [1, 2, 3], [1, 2]]
    ///
    /// - Parameter key: Closure to transform `Element` to `Bool`
    /// - Returns: Array of `[Element]`
    func chunked(at shouldStartNewChunk: (Element) -> Bool) -> [[Element]] {
        
        var groups = [[Element]]()
        
        func addGroup(_ groupToAdd: [Element]) {
            if groupToAdd.isEmpty == false {
                groups.append(groupToAdd)
            }
        }
        
        var currentGroup = [Element]()
        
        for item in self {
            if shouldStartNewChunk(item) {
                addGroup(currentGroup)
                currentGroup.removeAll()
            }
            currentGroup.append(item)
        }
        
        addGroup(currentGroup)
        return groups
    }
}

// MARK: - Chunked Ascending / Descending

public extension Array where Element: Comparable {
    
    /// Returns `[[Element]]` where the inner arrays are ascending groupings of each
    /// same value of `Element`
    ///
    ///     [2, 1, 4, 3, 2, 1, 3, 1].chunkedAscending()
    ///     // [[1, 1, 1], [2, 2], [3, 3], [4]]
    ///
    /// - Returns: Array of `[Element]`
    func chunkedAscending() -> [[Element]] {
        return self.sortedAscending().chunked(atChangeTo: { $0 })
    }
    
    /// Returns `[[Element]]` where the inner arrays are descending groupings of each
    /// same value of `Element`
    ///
    ///     [2, 1, 4, 3, 2, 1, 3, 1].chunkedDescending()
    ///     // [[4], [3, 3], [2, 2], [1, 1, 1]]
    ///
    /// - Returns: Array of `[Element]`
    func chunkedDescending() -> [[Element]] {
        return self.sortedDescending().chunked(atChangeTo: { $0 })
    }
}

// MARK: - Chunked Ascending / Descending By

public extension Array {
    
    /// Returns `[[Element]]` where the inner arrays are ascending groupings of each
    /// same value of the result of `key(element)`
    ///
    ///     ["ab", "a", "abc", "ab", "a", "abc", "a"].chunkedAscendingBy { $0.count }
    ///     // [["a", "a", "a"], ["ab", "ab"], ["abc", "abc"]]
    ///
    /// - Parameter key: Closure to transform `Element` to `Comparable`
    /// - Returns: Array of `[Element]`
    func chunkedAscendingBy<T: Comparable>(key: (Element) -> T) -> [[Element]] {
        return self.sortedAscendingBy(key).chunked(atChangeTo: key)
    }
    
    /// Returns `[[Element]]` where the inner arrays are descending groupings of each
    /// same value of the result of `key(element)`
    ///
    ///     ["ab", "a", "abc", "ab", "a", "abc", "a"].chunkedDescendingBy { $0.count }
    ///     // [["abc", "abc"], ["ab", "ab"], ["a", "a", "a"]]
    ///
    /// - Parameter key: Closure to transform `Element` to `Comparable`
    /// - Returns: Array of `[Element]`
    func chunkedDescendingBy<T: Comparable>(key: (Element) -> T) -> [[Element]] {
        return self.sortedDescendingBy(key).chunked(atChangeTo: key)
    }
}
