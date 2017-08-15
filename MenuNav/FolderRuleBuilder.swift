//
//  FolderRuleBuilder.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - FolderRule Condition

extension FolderContentsMatcher {
    
    var inputString: String {
        switch self {
        case let .filesWithExtension(s):
            return s
        case let .filesWithFullName(s):
            return s
        case let .foldersWithName(s):
            return s
        }
    }
}

extension StringMatcher {
    
    var inputString: String {
        
        switch self {
        case let .containing(s):
            return s
        case let .notContaining(s):
            return s
        case let .matching(s):
            return s
        case let .notMatching(s):
            return s
        }
    }
}

extension PathMatcher {
    
    var inputString: String {
        
        switch self {
        case let .matching(s):
            return s
        case let .notMatching(s):
            return s
        }
    }
}
