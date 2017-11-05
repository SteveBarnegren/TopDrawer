//
//  File.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
@testable import MenuNav

extension DictionaryRepresentable {
    
    var convertedToDictionaryAndBack: Self {
        
        let dictionary = dictionaryRepresentation
        return Self(dictionaryRepresentation: dictionary)!
    }
}
