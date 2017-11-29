//
//  StringRepresentable.swift
//  MenuNav
//
//  Created by Steve Barnegren on 27/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

protocol StringRepresentable {
    
    init?(stringRepresentation: String)
    var stringRepresentation: String {get}
}
