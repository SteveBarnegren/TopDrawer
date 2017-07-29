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
        let target = targetDescription(fromRule: rule)
        guard let nameAndExtension = nameAndExtensionDescription(fromRule: rule) else {
            return nil
        }
        
        return filter + " " + target + " " + nameAndExtension
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
    
    private func targetDescription(fromRule rule: FileRule) -> String {
        
        switch rule.target {
        case .files(_, _):
            return "files"
        case .folders(_):
            return "folders"
        }
    }
    
    private func nameAndExtensionDescription(fromRule rule: FileRule) -> String? {
        
        switch (rule.itemName, rule.itemExtension) {
        case let (.some(name), .some(ext)):
            return "named \(name).\(ext)"
        case let (.some(name), nil):
            return "with name \(name)"
        case let (nil, .some(ext)):
            return "with extension \(ext)"
        case (nil, nil):
            return nil
        }
    }
}
