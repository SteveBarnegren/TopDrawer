//
//  Rule.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

// MARK: - ConditionProtocol

protocol CondtionProtocol {
    var displayDescription: String {get}
    func attributedDisplayDescription(withAttributes attributes: ConditionFormatterAttributes) -> NSAttributedString
}

// MARK: - Rule

protocol Rule: DictionaryRepresentable {
    
    associatedtype Condition: CondtionProtocol, DecisionTreeElement
    
    static var storageKey: String {get}
    
    init(conditions: [Condition])
    
    var numberOfConditions: Int {get}
    
    var conditions: [Condition] {get}
    
    static func makeDecisionTree() -> DecisionNode<Condition>
}

// MARK: - FormatterSupplier

protocol FormatterProvider {
    
    associatedtype T
    
    func string(from: T) -> String
}

// MARK: - Rule Loader

class RuleLoader<T: Rule> {
    
    let keyValueStore: KeyValueStore
    
    init(keyValueStore: KeyValueStore) {
        self.keyValueStore = keyValueStore
    }
    
    var numberOfRules: Int {
        return rules.count
    }
    
    var rules: [T] {
        get {
            let key = T.storageKey
            
            guard let array = keyValueStore.value(forKey: key) as? [[String: Any]] else {
                return []
            }
            return array.flatMap { T(dictionaryRepresentation: $0) }
        }
        set {
            let key = T.storageKey
            let array = newValue.map { $0.dictionaryRepresentation }
            keyValueStore.set(value: array, forKey: key)
        }
    }
    
    func add(rule: T) {
        rules = rules.appending(rule)
    }
    
    func update(rule: T, atIndex index: Int) {
        var copy = rules
        copy[index] = rule
        rules = copy
    }
    
    func deleteRule(atIndex index: Int) {
        var copy = rules
        copy.remove(at: index)
        rules = copy
    }
}
