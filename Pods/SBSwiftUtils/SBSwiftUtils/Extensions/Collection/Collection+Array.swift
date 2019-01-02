//
//  Collection+Array.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 19/08/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Collection {
    
    func toArray() -> [Element] {
        return Array(self)
    }
}
