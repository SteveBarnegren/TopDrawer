//
//  Interval.swift
//  MenuNav
//
//  Created by Steve Barnegren on 05/11/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

enum Interval {
    case seconds(Int)
    case minutes(Int)
    case hours(Int)
    case never
    
    var title: String {
        switch self {
        case let .seconds(val):
            return string(fromUnit: "Second", value: val)
        case let .minutes(val):
            return string(fromUnit: "Minute", value: val)
        case let .hours(val):
            return string(fromUnit: "Hour", value: val)
        case .never:
            return "Never"
        }
    }
    
    private func string(fromUnit unit: String, value: Int) -> String {
        if value == 1 {
            return "\(value) \(unit)"
        } else {
            return "\(value) \(unit)s"
        }
    }
    
    var secondsValue: Double {
        switch self {
        case let .seconds(s):
            return Double(s)
        case let .minutes(m):
            return Double(m * 60)
        case let .hours(h):
            return Double(h * 60 * 60)
        case .never:
            return Double(-1)
        }
    }
    
    var minutesValue: Double {
        return secondsValue / 60
    }
    
    var hoursValue: Double {
        return minutesValue / 60
    }
}
