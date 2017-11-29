//
//  HierarchyInformation.swift
//  MenuNav
//
//  Created by Steve Barnegren on 21/10/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

struct HierarchyInformation {
    
    private var folderNames = [String]()
    
    mutating func add(folderName: String) {
        folderNames.append(folderName)
    }
    
    func containsFolder(where closure: (String) -> (Bool)) -> Bool {
        return folderNames.contains(where: closure)
    }
}
