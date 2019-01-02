//
//  WeakArray.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 18/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

private struct WeakItemWrapper<T: AnyObject> {
    
    private weak var p_object: T?
    
    init(object: T) {
        p_object = object
    }
    
    var object: T? {
        return p_object
    }
}

/// A array implementation that holds it's items weakly. If an item becomes
/// deallocated then it will be removed from the array
public struct WeakArray<T: AnyObject>: RandomAccessCollection, Sequence {
    
    // MARK: - Manage wrapped items
    
    private var wrappedItems: [WeakItemWrapper<T>]
    
    public mutating func removeDeallocatedItems() {
        wrappedItems = wrappedItems.filter { $0.object != nil }
    }
    
    private var unwrappedItems: [T] {
        return wrappedItems.compactMap { $0.object }
    }
    
    // MARK: - Init
    
    public init() {
        wrappedItems = [WeakItemWrapper<T>]()
    }
    
    public init(objects: [T]) {
        wrappedItems = objects.map(WeakItemWrapper.init)
    }
    
    public init(objects: T...) {
        wrappedItems = objects.map(WeakItemWrapper.init)
    }
    
    // MARK: - Add / Remove
    
    public mutating func append(_ newElement: T) {
        removeDeallocatedItems()
        wrappedItems.append( WeakItemWrapper(object: newElement) )
    }
    
    public mutating func remove(where shouldRemove: (T) -> Bool) {
        
        wrappedItems = wrappedItems
            .compactMap { $0.object }
            .filter { !shouldRemove($0) }
            .map(WeakItemWrapper.init)
    }
    
    // MARK: - Contains
    
    public func contains(object: T) -> Bool {
        return contains { $0 === object }
    }
    
    // MARK: - For Each
    
    public func forEach(_ body: @escaping (Element) throws -> Void) rethrows {
        try unwrappedItems.forEach(body)
    }
    
    // For-in
    
    public func makeIterator() -> IndexingIterator<[T]> {
        return unwrappedItems.makeIterator()
    }
    
    // MARK: - RandomAccessCollection conformance
    
    public typealias Index = Int
    public typealias Element = T
    
    public var startIndex: Index { return unwrappedItems.startIndex }
    public var endIndex: Index { return unwrappedItems.endIndex }
    
    public subscript(index: Index) -> Element {
        return unwrappedItems[index]
    }
    
    public func index(after i: Index) -> Index {
        return unwrappedItems.index(after: i)
    }
    
    public func index(before i: WeakArray<T>.Index) -> WeakArray<T>.Index {
        return unwrappedItems.index(before: i)
    }
}
