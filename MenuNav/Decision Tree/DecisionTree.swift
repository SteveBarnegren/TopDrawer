//
//  DecisionTree.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - Decision Tree Types

protocol DecisionTreeElement: Equatable {
    /** Returns the input required to reconstruct the value from a decision tree */
    func decisionTreeInput() -> String
}

enum DecisionNodeType<T: DecisionTreeElement> {
    case list(String, [DecisionNode<T>])
    case textValue(String, placeholder: String, make: (String) -> (T?))
    case pathValue(String, placeholder: String, make: (String) -> (T?))
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
        case let .pathValue(name, _, _):
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
            } else {
                return nil
            }
            
        case let .pathValue(_, _, makeWithPath):
            if let text = textValue {
                return makeWithPath(text)
            } else {
                return nil
            }
            
        }
    }
    
    @discardableResult func matchTree(toElement element: T) -> Bool {
        
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
            
        case let .pathValue(_, _, handler):
            if let value = handler(input), value == element {
                textValue = input
                return true
            }
            return false
        }
    }
}

// MARK: - File Condtion Decision Tree

// swiftlint:disable line_length
func fileConditionDecisionTree() -> DecisionNode<FileRule.Condition> {
    
    let nameNode = DecisionNode<FileRule.Condition>(.list("Name", [
        DecisionNode(.textValue("is", placeholder: "Name") { .name(.matching($0)) }),
        DecisionNode(.textValue("is not", placeholder: "Name") { .name(.notMatching($0)) }),
        DecisionNode(.textValue("contains", placeholder: "String") { .name(.containing($0)) }),
        DecisionNode(.textValue("does not contain", placeholder: "String") { .name(.notContaining($0)) })
        ]))
    
    let extensionNode =  DecisionNode<FileRule.Condition>(.list("Extension", [
        DecisionNode(.textValue("is", placeholder: "eg. pdf") { .ext(.matching($0)) }),
        DecisionNode(.textValue("is not", placeholder: "eg. pdf") { .ext(.notMatching($0)) })
        ]))
    
    let fullNameNode =  DecisionNode<FileRule.Condition>(.list("Full name", [
        DecisionNode(.textValue("is", placeholder: "eg. report.pdf") { .fullName(.matching($0)) }),
        DecisionNode(.textValue("is not", placeholder: "eg. report.pdf") { .fullName(.notMatching($0)) })
        ]))
    
    let parentFolderNode = DecisionNode<FileRule.Condition>(.list("Parent Folder", [
        DecisionNode(.list("contains", [
            DecisionNode(.textValue("files with extension", placeholder: "eg. pdf") { .parentContains(.filesWithExtension($0)) }),
            DecisionNode(.textValue("files with full name", placeholder: "eg. report.pdf") { .parentContains(.filesWithFullName($0)) })
            ])),
        DecisionNode(.list("doesn't contain", [
            DecisionNode(.textValue("files with extension", placeholder: "eg. pdf") { .parentDoesntContain(.filesWithExtension($0)) }),
            DecisionNode(.textValue("files with full name", placeholder: "eg. report.pdf") { .parentDoesntContain(.filesWithFullName($0)) })
            ]))
        ]))
    
    let hierarchyNode =  DecisionNode<FileRule.Condition>(.list("Hierarchy", [
        DecisionNode(.list("contains", [
            DecisionNode(.textValue("folder with name", placeholder: "eg. documents") { .hierarchyContains(.folderWithName(.matching($0))) })
            ]))
        ]))
    
    return DecisionNode<FileRule.Condition>(.list("root", [
        nameNode,
        extensionNode,
        fullNameNode,
        parentFolderNode,
        hierarchyNode
        ]))
}

// MARK: - Folder Condtion Decision Tree

func folderConditionDecisionTree() -> DecisionNode<FolderRule.Condition> {
    
    func fileNameAndExtensionFromInput(_ string: String) -> (String, String)? {
        
        let components = string.components(separatedBy: ".")
        if components.count != 2 {
            return nil
        }
        
        if components.contains(where: { $0.length == 0 }) {
            return nil
        }
        
        return (components[0], components[1])
    }
    
    // 'Expression was too complex to be solved in a reasonable amount of time', so split up the top level items
    
    let name = DecisionNode<FolderRule.Condition>(.list("Name", [
        DecisionNode(.textValue("is", placeholder: "Name") { .name(.matching($0)) }),
        DecisionNode(.textValue("is not", placeholder: "Name") { .name(.notMatching($0)) }),
        DecisionNode(.textValue("contains", placeholder: "Name") { .name(.containing($0)) }),
        DecisionNode(.textValue("does not contain", placeholder: "Name") { .name(.notContaining($0)) })
        ]))
    
    let path = DecisionNode<FolderRule.Condition>(.list("Path", [
        DecisionNode(.pathValue("is", placeholder: "Path") { .path(.matching($0)) }),
        DecisionNode(.textValue("is not", placeholder: "Path") { .path(.notMatching($0)) })
        ]))
    
    let contains = DecisionNode<FolderRule.Condition>(.list("Contains", [
        DecisionNode(.list("files", [
            DecisionNode(.textValue("with extension", placeholder: "Extension") { .contains(.filesWithExtension($0)) }),
            DecisionNode(.textValue("with full name", placeholder: "Full name (eg. report.pdf)") { .contains(.filesWithFullName($0)) })
            ])),
        DecisionNode(.list("folders", [
            DecisionNode(.textValue("with name", placeholder: "Extension") { .contains(.foldersWithName($0)) })
            ]))
        ]))
    
    let doesntContain = DecisionNode<FolderRule.Condition>(.list("Doesn't contain", [
        DecisionNode(.list("files", [
            DecisionNode(.textValue("with extension", placeholder: "Extension") { .doesntContain(.filesWithExtension($0)) }),
            DecisionNode(.textValue("with full name", placeholder: "Full name (eg. report.pdf)") { .doesntContain(.filesWithFullName($0)) })
            ])),
        DecisionNode(.list("folders", [
            DecisionNode(.textValue("with name", placeholder: "Extension") { .doesntContain(.foldersWithName($0)) })
            ]))
        ]))
    
    return
        DecisionNode<FolderRule.Condition>(.list("root", [
            name,
            path,
            contains,
            doesntContain
            ]))
}
