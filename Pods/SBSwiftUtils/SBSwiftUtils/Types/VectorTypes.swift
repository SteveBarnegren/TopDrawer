//
//  VectorTypes.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 15/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

/// A generic Vector2 type
public struct Vector2<T: Any> {
    
    public init(_ v0: T, _ v1: T) {
        self.v0 = v0
        self.v1 = v1
    }
    
    public init(x: T, y: T) {
        self.v0 = x
        self.v1 = y
    }
    
    public var v0: T
    public var v1: T
    
    public var x: T {
        get { return v0 }
        set { v0 = newValue }
    }
    public var y: T {
        get { return v1 }
        set { v1 = newValue }
    }
}

/// A generic Vector3 type
public struct Vector3<T: Any> {
    
    public init(_ v0: T, _ v1: T, _ v2: T) {
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
    }
    
    public init(x: T, y: T, z: T) {
        self.v0 = x
        self.v1 = y
        self.v2 = z
    }
    
    public init(r: T, g: T, b: T) {
        self.v0 = r
        self.v1 = g
        self.v2 = b
    }
    
    public var v0: T
    public var v1: T
    public var v2: T
    
    public var x: T {
        get { return v0 }
        set { v0 = newValue }
    }
    public var y: T {
        get { return v1 }
        set { v1 = newValue }
    }
    public var z: T {
        get { return v2 }
        set { v2 = newValue }
    }
    
    public var r: T {
        get { return v0 }
        set { v0 = newValue }
    }
    public var g: T {
        get { return v1 }
        set { v1 = newValue }
    }
    public var b: T {
        get { return v2 }
        set { v2 = newValue }
    }

}

/// A generic Vector4 type
public struct Vector4<T: Any> {
    
    public init(_ v0: T, _ v1: T, _ v2: T, _ v3: T) {
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
        self.v3 = v3
    }
    
    public init(x: T, y: T, z: T, w: T) {
        self.v0 = x
        self.v1 = y
        self.v2 = z
        self.v3 = w
    }
    
    public init(r: T, g: T, b: T, a: T) {
        self.v0 = r
        self.v1 = g
        self.v2 = b
        self.v3 = a
    }
    
    public var v0: T
    public var v1: T
    public var v2: T
    public var v3: T
    
    public var x: T {
        get { return v0 }
        set { v0 = newValue }
    }
    public var y: T {
        get { return v1 }
        set { v1 = newValue }
    }
    public var z: T {
        get { return v2 }
        set { v2 = newValue }
    }
    public var w: T {
        get { return v3 }
        set { v3 = newValue }
    }
    
    public var r: T {
        get { return v0 }
        set { v0 = newValue }
    }
    public var g: T {
        get { return v1 }
        set { v1 = newValue }
    }
    public var b: T {
        get { return v2 }
        set { v2 = newValue }
    }
    public var a: T {
        get { return v3 }
        set { v3 = newValue }
    }

}
