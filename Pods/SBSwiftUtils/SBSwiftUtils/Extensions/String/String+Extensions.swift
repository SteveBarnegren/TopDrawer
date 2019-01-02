//
//  String+Extensions.swift
//  SBSwiftUtils
//
//  Created by Steven Barnegren on 25/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

public extension String {
    
    /// The length of the `String`
    var length: Int {
        return count
    }
    
    /// Creates a new string the leading and trailing whitespace trimmed
    ///
    /// - Returns: A `String` instance
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// The path extension of a url
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    /// Creates a new `String` without the path extension
    ///
    /// - Returns: A `String` instance
    func deletingPathExtension() -> String {
        return (self as NSString).deletingPathExtension
    }
    
    /// Used to query if the `String` contains a another string
    ///
    /// - Parameter subString: The substring
    /// - Returns: `true` if the string contains `subString`
    func contains(subString: String) -> Bool {
        return self.range(of: subString) != nil
    }
}
