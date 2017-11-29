//
//  DictionaryRepresentable.swift
//  MenuNav
//
//  Created by Steve Barnegren on 25/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

protocol DictionaryRepresentable {

    init?(dictionaryRepresentation: [String: Any])
    var dictionaryRepresentation: [String: Any] {get}
}
