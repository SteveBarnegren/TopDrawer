//
//  IntervalTests.swift
//  MenuNavTests
//
//  Created by Steve Barnegren on 05/11/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest
@testable import TopDrawer

class IntervalTests: XCTestCase {
    
    let comparisonAccuracy = 0.0001
    
    // MARK: - Test accessors

    func testIntervalsReturnCorrectSecondsValues() {
        
        XCTAssertEqual(Interval.seconds(0).secondsValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.seconds(1).secondsValue, 1, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.seconds(3).secondsValue, 3, accuracy: comparisonAccuracy)
        
        XCTAssertEqual(Interval.minutes(0).secondsValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.minutes(1).secondsValue, 60, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.minutes(3).secondsValue, 60 * 3, accuracy: comparisonAccuracy)
        
        XCTAssertEqual(Interval.hours(0).secondsValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.hours(1).secondsValue, 60 * 60, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.hours(3).secondsValue, 60 * 60 * 3, accuracy: comparisonAccuracy)
        
        XCTAssertEqual(Interval.never.secondsValue, -1, accuracy: comparisonAccuracy)
    }
    
    func testIntervalsReturnCorrectMinutesValues() {
        
        XCTAssertEqual(Interval.seconds(0).minutesValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.seconds(1).minutesValue, 1 / 60, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.seconds(3).minutesValue, 1 / 60 * 3, accuracy: comparisonAccuracy)
        
        XCTAssertEqual(Interval.minutes(0).minutesValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.minutes(1).minutesValue, 1, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.minutes(3).minutesValue, 3, accuracy: comparisonAccuracy)
        
        XCTAssertEqual(Interval.hours(0).minutesValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.hours(1).minutesValue, 60, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.hours(3).minutesValue, 3 * 60, accuracy: comparisonAccuracy)
    }
    
    func testIntervalsReturnCorrectHoursValues() {
        
        XCTAssertEqual(Interval.seconds(0).hoursValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.seconds(1).hoursValue, 1 / 60 / 60, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.seconds(3).hoursValue, 1 / 60 / 60 * 3, accuracy: comparisonAccuracy)
        
        XCTAssertEqual(Interval.minutes(0).hoursValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.minutes(1).hoursValue, 1 / 60, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.minutes(3).hoursValue, 3 / 60, accuracy: comparisonAccuracy)
        
        XCTAssertEqual(Interval.hours(0).hoursValue, 0, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.hours(1).hoursValue, 1, accuracy: comparisonAccuracy)
        XCTAssertEqual(Interval.hours(3).hoursValue, 3, accuracy: comparisonAccuracy)
    }
    
    // Test Readouts

    func testIntervalReadouts() {
        
        XCTAssertEqual(Interval.seconds(0).title, "0 Seconds")
        XCTAssertEqual(Interval.seconds(1).title, "1 Second")
        XCTAssertEqual(Interval.seconds(2).title, "2 Seconds")
        
        XCTAssertEqual(Interval.minutes(0).title, "0 Minutes")
        XCTAssertEqual(Interval.minutes(1).title, "1 Minute")
        XCTAssertEqual(Interval.minutes(2).title, "2 Minutes")
        
        XCTAssertEqual(Interval.hours(0).title, "0 Hours")
        XCTAssertEqual(Interval.hours(1).title, "1 Hour")
        XCTAssertEqual(Interval.hours(2).title, "2 Hours")
        
        XCTAssertEqual(Interval.never.title, "Never")
    }

}
