//
//  MockTimerBenign.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

class MockTimerBenign: Timer {
    
    required init(interval: TimeInterval, target: AnyObject, selector: Selector, repeats: Bool, pctTolerance: Double) {}
    
    func start() {}

    func stop() {}
}
