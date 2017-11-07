//
//  RebuildResultsFormatter.swift
//  MenuNav
//
//  Created by Steve Barnegren on 05/11/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

class RebuildResultsFormatter {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
       return dateFormatter
    }()
    
    func lastRefreshString(fromResult rebuildResult: RebuildManager.Result) -> String {
        
        switch rebuildResult {
        case .success(_, let date):
            let dateString = RebuildResultsFormatter.dateFormatter.string(from: date)
            return "Last refresh: \(dateString)"
            
        case .tookTooLong(let date):
            let dateString = RebuildResultsFormatter.dateFormatter.string(from: date)
            return "Last attempt: \(dateString)"
            
        case .none:
            return "No result"
        }
    }
    
    func lastStatusString(fromResult rebuildResult: RebuildManager.Result) -> String {
        
        switch rebuildResult {
        case .success(let timeTaken, _):
            let seconds = max(Int(timeTaken), 1)
            let unit = seconds == 1 ? "second" : "seconds"
            return "Took \(seconds) \(unit)"
            
        case .tookTooLong:
            return "Cancelled, took too long"
            
        case .none:
            return "No status"
        }
    }
}
