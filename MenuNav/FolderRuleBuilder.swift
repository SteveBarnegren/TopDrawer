//
//  FolderRuleBuilder.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

class FolderConditionBulder {
    
    enum ConditonType {
        case name
        case path
        case contains
    }
}

class FolderRuleBuilder {
    
    var matchType = FolderRule.MatchType.all
    
    
    
    
}

// Do we need the stuff above here???? ^^^^^^^

protocol DecisionTreeElement: Equatable {
    /** Returns the input required to reconstruct the value from a decision tree */
    func decisionTreeInput() -> String
}

enum DecisionNodeType<T: DecisionTreeElement> {
    case list(String, [DecisionNode<T>])
    case textValue(String, placeholder: String, make: (String) -> (T?))
}

class DecisionNode<T: DecisionTreeElement> {
    
    var selectedIndex = 0
    var textValue: String?
    let nodeType: DecisionNodeType<T>
    
    init(_ type: DecisionNodeType<T>) {
        self.nodeType = type
    }
    
    var name: String {
        switch nodeType {
        case let .list(name, _):
            return name
        case let .textValue(name, _, _):
            return name
        }
    }
    
    func make() -> T? {
        
        switch nodeType {
        case let .list(_, nodes):
            return nodes[selectedIndex].make()
            
        case let .textValue(_, _, makeWithText):
            if let text = textValue {
                return makeWithText(text)
            }
            else{
                return nil
            }
        }
    }
    
    func matchTree(toElement element: T) -> Bool {
        
        print("node: \(self.nodeType)")
        
        let input = element.decisionTreeInput()
        
        switch self.nodeType {
        case let .list(_, nodes):
            for (index, node) in nodes.enumerated() {
                if node.matchTree(toElement: element) {
                    selectedIndex = index
                    return true
                }
            }
            
            return false
            
        case let .textValue(_, _, handler):
            if let value = handler(input), value == element {
                textValue = input
                return true
            }
            return false
        }
    }
}

func folderConditionDecisionTree() -> DecisionNode<FolderRule.Condition> {
    
    func fileNameAndExtensionFromInput(_ string: String) -> (String, String)? {
        
        let components = string.components(separatedBy: ".")
        if components.count != 2 {
            return nil
        }
        
        for component in components {
            if component.length == 0 {
                return nil
            }
        }
        
        return (components[0], components[1])
    }
    
    // 'Expression was too complex to be solved in a reasonable amount of time', so split up the top level items
    
    let name = DecisionNode<FolderRule.Condition>(.list("Name", [
        DecisionNode(.textValue("is", placeholder: "Name"){ .name(.matching($0)) }),
        DecisionNode(.textValue("is not", placeholder: "Name"){ .name(.notMatching($0)) }),
        DecisionNode(.textValue("contains", placeholder: "Name"){ .name(.containing($0)) }),
        DecisionNode(.textValue("does not contain", placeholder: "Name"){ .name(.notContaining($0)) }),
        ]))
    
    let path = DecisionNode<FolderRule.Condition>(.list("Path", [
        DecisionNode(.textValue("is", placeholder: "Path"){ .path(.matching($0)) }),
        DecisionNode(.textValue("is not", placeholder: "Path"){ .path(.notMatching($0)) }),
        ]))
    
    let contains = DecisionNode<FolderRule.Condition>(.list("Contains", [
        DecisionNode(.list("files", [
            DecisionNode(.textValue("with extension", placeholder: "Extension"){ .contains(.filesWithExtension($0)) }),
            DecisionNode(.textValue("with full name", placeholder: "Full name (eg. report.pdf)"){
                
                if let inputs = fileNameAndExtensionFromInput($0) {
                    return .contains(.filesWithNameAndExtension(name: inputs.0, ext: inputs.1))
                }
                else{
                    return nil
                }
                }),
            ])),
        DecisionNode(.list("folders", [
            DecisionNode(.textValue("with name", placeholder: "Extension"){ .contains(.foldersWithName($0)) }),
            ])),
        ]))
    
    let doesntContain = DecisionNode<FolderRule.Condition>(.list("Doesn't contain", [
        DecisionNode(.list("files", [
            DecisionNode(.textValue("with extension", placeholder: "Extension"){ .doesntContain(.filesWithExtension($0)) }),
            DecisionNode(.textValue("with full name", placeholder: "Full name (eg. report.pdf)"){
                
                if let inputs = fileNameAndExtensionFromInput($0) {
                    return .doesntContain(.filesWithNameAndExtension(name: inputs.0, ext: inputs.1))
                }
                else{
                    return nil
                }
                }),
            
            ])),
        DecisionNode(.list("folders", [
            DecisionNode(.textValue("with name", placeholder: "Extension"){ .doesntContain(.foldersWithName($0)) }),
            ])),
        ]))
    
    return
        DecisionNode<FolderRule.Condition>(.list("root", [
            name,
            path,
            contains,
            doesntContain,
            ]))
    
    
    /*
     return
     DecisionNode<FolderRule.Condition>(.list("root", [
     DecisionNode(.list("Name", [
     DecisionNode(.textValue("is", placeholder: "Name"){ .name(.matching($0)) }),
     DecisionNode(.textValue("is not", placeholder: "Name"){ .name(.notMatching($0)) }),
     DecisionNode(.textValue("contains", placeholder: "Name"){ .name(.containing($0)) }),
     DecisionNode(.textValue("does not contain", placeholder: "Name"){ .name(.notContaining($0)) }),
     ])),
     DecisionNode(.list("Path", [
     DecisionNode(.textValue("is", placeholder: "Path"){ .path(.matching($0)) }),
     DecisionNode(.textValue("is not", placeholder: "Path"){ .path(.notMatching($0)) }),
     ])),
     DecisionNode(.list("Contains", [
     DecisionNode(.list("files", [
     DecisionNode(.textValue("with extension", placeholder: "Extension"){ .contains(.filesWithExtension($0)) }),
     DecisionNode(.textValues("with name and extension", placeholders: ["Name", "Extension"]){
     .contains(.filesWithNameAndExtension(name: $0[0], ext: $0[1]))
     }),
     ])),
     DecisionNode(.list("folders", [
     DecisionNode(.textValue("with name", placeholder: "Extension"){ .contains(.foldersWithName($0)) }),
     ])),
     ])),
     DecisionNode(.list("Doesn't contain", [
     DecisionNode(.list("files", [
     DecisionNode(.textValue("with extension", placeholder: "Extension"){ .doesntContain(.filesWithExtension($0)) }),
     DecisionNode(.textValues("with name and extension", placeholders: ["Name", "Extension"]){
     .doesntContain(.filesWithNameAndExtension(name: $0[0], ext: $0[1]))
     }),
     ])),
     DecisionNode(.list("folders", [
     DecisionNode(.textValue("with name", placeholder: "Extension"){ .doesntContain(.foldersWithName($0)) }),
     ])),
     ]))
     ]))
     */
}



// MARK: - FolderRule Condition

extension FolderRule.ContentsMatcher {
    
    var inputString: String {
        switch self {
        case let .filesWithExtension(s):
            return s
        case let .filesWithNameAndExtension(name, ext):
            return "\(name).\(ext)"
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

extension FolderRule.Condition: DecisionTreeElement {
    
    func decisionTreeInput() -> String {
        switch self {
        case let .contains(contentsMatcher):
            return contentsMatcher.inputString
        case let .doesntContain(contentsMatcher):
            return contentsMatcher.inputString
        case let .name(stringMatcher):
            return stringMatcher.inputString
        case let .path(pathMatcher):
            return pathMatcher.inputString
        }
    }
}












