//
//  Array+SortBySteps.swift
//  SBSwiftUtils
//
//  Created by Steve Barnegren on 11/02/2018.
//  Copyright © 2018 SteveBarnegren. All rights reserved.
//

import Foundation

public extension Array {
    
    public class SortStep<Input> {
        
        public enum Result {
            case ascending
            case descending
            case equal
        }
        
        private let sortClosure: (Input, Input) -> Result
        
        public init(sortClosure: @escaping (Input, Input) -> Result) {
            self.sortClosure = sortClosure
        }
        
        public convenience init<Output: Comparable>(ascending transform: @escaping (Input) -> Output) {
            self.init { (lhs, rhs) -> Result in
                let lhsComparable = transform(lhs)
                let rhsComparable = transform(rhs)
                
                if lhsComparable == rhsComparable {
                    return .equal
                } else {
                    return rhsComparable > lhsComparable ? .ascending : .descending
                }
            }
        }
        
        public convenience init<Output: Comparable>(descending transform: @escaping (Input) -> Output) {
            self.init { (lhs, rhs) -> Result in
                let lhsComparable = transform(lhs)
                let rhsComparable = transform(rhs)
                
                if lhsComparable == rhsComparable {
                    return .equal
                } else {
                    return rhsComparable < lhsComparable ? .ascending : .descending
                }
            }
        }
        
        fileprivate func sort(lhs: Input, rhs: Input) -> Result {
            return sortClosure(lhs, rhs)
        }
    }
    
    mutating func sortBySteps(_ steps: [SortStep<Element>]) {
        
        if steps.isEmpty {
            return
        }
        
        sort { (lhs, rhs) -> Bool in
            
            var index = 0
            while let step = steps[maybe: index] {
                
                let result = step.sort(lhs: lhs, rhs: rhs)
                switch result {
                case .ascending: return true
                case .descending: return false
                case .equal: break
                }
                
                index += 1
            }
            
            return true
        }
    }
    
    mutating func sortBySteps(_ steps: SortStep<Element>...) {
        sortBySteps(steps)
    }
    
    func sortedBySteps(_ steps: SortStep<Element>...) -> [Element] {
        return sortedBySteps(steps)
    }
    
    func sortedBySteps(_ steps: [SortStep<Element>]) -> [Element] {
        var sortedArray = self
        sortedArray.sortBySteps(steps)
        return sortedArray
    }
}
