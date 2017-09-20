//
//  Timer.swift
//  MenuNav
//
//  Created by Steve Barnegren on 11/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

protocol Timer {
    init(interval: TimeInterval, target: AnyObject, selector: Selector, repeats: Bool, pctTolerance: Double)
    func start()
    func stop()
}

final class NSTimerBasedTimer: Timer {
    
    private var nsTimer: Foundation.Timer?
    private let interval: TimeInterval
    private weak var target: AnyObject?
    private let selector: Selector
    private let repeats: Bool
    private let pctTolerance: Double
    private var isSpent = false
    
    init(interval: TimeInterval, target: AnyObject, selector: Selector, repeats: Bool, pctTolerance: Double) {
        self.interval = interval
        self.target = target
        self.selector = selector
        self.repeats = repeats
        self.pctTolerance = pctTolerance
    }
    
    func start() {
        
        if isSpent {
            return
        }
        
        nsTimer = Foundation.Timer(timeInterval: interval,
                                   target: self,
                                   selector: #selector(timerCallBack),
                                   userInfo: nil,
                                   repeats: repeats)
        
        nsTimer?.tolerance = interval * pctTolerance
        
        let runLoop = RunLoop.current
        runLoop.add(nsTimer!, forMode: .commonModes)
        
        isSpent = true
    }
    
    func stop() {
        nsTimer?.invalidate()
        nsTimer = nil
    }
    
    @objc private func timerCallBack() {
        _ = target?.perform(selector)
    }
    
}
