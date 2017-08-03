//
//  FileRuleFormatter.swift
//  MenuNav
//
//  Created by Steve Barnegren on 29/07/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

struct FileRuleFormatter {
    
    func string(fromRule rule: FileRule) -> String? {
                
        let filter = filterDescription(fromRule: rule)
        let nameAndExtension = nameAndExtensionDescription(fromRule: rule)
        
        return filter + " files " + nameAndExtension
    }
    
    // MARK: - Component Descriptions
    
    private func filterDescription(fromRule rule: FileRule) -> String {
        
        switch rule.filter {
        case .include:
            return "Include"
        case .exclude:
            return "Exclude"
        }
    }
    
    private func nameAndExtensionDescription(fromRule rule: FileRule) -> String {
        
        switch rule.target {
        case let .matchingName(name):
            return "with name \(name)"
        case let .matchingExtension(ext):
            return "with extension \(ext)"
        case let .matchingNameAndExtension(name, ext):
            return "named \(name).\(ext)"
        }
    }
}
