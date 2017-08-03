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

// MARK: - Choices
/*
enum FNode {
    case list(String, [FNode])
    case textValue(String, placeholder: String, make: (String) -> (FolderRule.Condition))
    case textValues(String, placeholders: [String], make: ([String]) -> (FolderRule.Condition))
    
    var name: String {
        switch self {
        case let .list(name, _):
            return name
        case let .textValue(name, _, _):
            return name
        case let .textValues(name, _, _):
            return name
        }
    }
    
    func makeCondition(path: String, inputs: [String]) -> FolderRule.Condition? {
        
        switch self {
        case let .list(_, nodes):
            
            let nodeNames = path.components(separatedBy: "/")
            
            guard
                let name = nodeNames.first,
                let next = nodes.first(where:{ $0.name == name })
            else {
                return nil
            }
            
            let remainingPath = nodeNames.dropFirst().joined(separator: "/")
            return next.makeCondition(path: remainingPath, inputs: inputs)
            
        case let .textValue(_, _, make):
            
            guard let input = inputs.first else {
                return nil
            }
            
            return make(input)
            
        case let .textValues(_, placeholders, make):
            
            guard placeholders.count == inputs.count else {
                return nil
            }
            
            return make(inputs)
        }
    }
    
    func subpath(withPath path: String) -> FNode {
        
        let nodeNames = path.components(separatedBy: "/")
        
        switch self {
        case .list(<#T##String#>, <#T##[FNode]#>):
            <#code#>
        default:
            <#code#>
        }
        
        
        
    }
}

let tree = FNode.list("root", [
    .list("Name", [
        .textValue("is", placeholder:"Name") { .name(.matching($0)) },
        .textValue("contains", placeholder:"Path") { .name(.contains($0)) },
        ]),
    .textValue("Path is", placeholder:"Path") { .path($0) },
    .list("Contains files", [
        .textValue("with extension", placeholder:"Extension") { .contains(.filesWithExtension($0)) },
        .textValues("with name and extension", placeholders:["Name", "Extension"]) {
            .contains(.filesWithNameAndExtension(name: $0[0], ext: $0[1]))
        },
        ])
    ])
*/


// As struct

enum DecisionNodeType<T> {
    case list(String, [DecisionNode<T>])
    case textValue(String, placeholder: String, make: (String) -> (T))
    case textValues(String, placeholders: [String], make: ([String]) -> (T))
}

class DecisionNode<T> {
    
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
        case let .textValues(name, _, _):
            return name
        }
    }
}

func folderConditionDecisionTree() -> DecisionNode<FolderRule.Condition> {
    
    return
        DecisionNode<FolderRule.Condition>(.list("root", [
            DecisionNode(.list("Name", [
                DecisionNode(.textValue("is", placeholder: "Name"){ .name(.matching($0)) }),
                DecisionNode(.textValue("contains", placeholder: "Name"){ .name(.contains($0)) }),
                ])),
            DecisionNode(.textValue("Path is", placeholder: "Path"){ .path($0) }),
            DecisionNode(.list("Contains files", [
                DecisionNode(.textValue("with extension", placeholder: "Extension"){ .contains(.filesWithExtension($0)) }),
                DecisionNode(.textValues("with name and extension", placeholders: ["Name", "Extension"]){
                    .contains(.filesWithNameAndExtension(name: $0[0], ext: $0[1]))
                    }),
                ])),
            ]))
}












