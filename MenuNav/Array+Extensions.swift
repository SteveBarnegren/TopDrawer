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
