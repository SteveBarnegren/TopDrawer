//
//  Optional+Bool.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 13/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Optional where Wrapped == Bool {
    
    /// Can be used to test optional bools for 'falseness'. For chained optionals, wrap
    /// in parentheses to 'flatten' the type
    ///
    ///     if (optionalType?.boolValue).isNilOrFalse {
    ///         ...
    ///     }
    ///
    var isNilOrFalse: Bool {
        
        switch self {
        case .none:
            return true
        case .some(let value):
            return !value
        }
    }

    /// Can be used to test optional bools for 'trueness'. Will be false if the optional
    /// is `nil`. For chained optionals, wrap in parentheses to 'flatten' the type
    ///     if (optionalType?.boolValue).isTrue {
    ///         ...
    ///     }
    ///
    var isTrue: Bool {
        
        switch self {
        case .none:
            return false
        case .some(let value):
            return value
        }
    }
}
