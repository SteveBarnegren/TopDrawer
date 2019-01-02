//
//  Substring+Extensions.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 11/11/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Substring {
    
    /// Converts the Substring to a String
    ///
    /// - Returns: A String with the contents of the Substring
    func toString() -> String {
        return String(self)
    }
}
