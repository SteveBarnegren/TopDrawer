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
        
        let dateString = RebuildResultsFormatter.dateFormatter.string(from: rebuildResult.date)

        switch rebuildResult.type {
        case .success, .noMatchingFiles:
            return "Last refresh: \(dateString)"
        case .tookTooLong, .invalidRootPath, .noRootPathSet, .unknownError:
            return "Last attempt: \(dateString)"
        case .none:
            return "None"
        }
    }
    
    func lastStatusString(fromResult rebuildResult: RebuildManager.Result) -> String {
        
        switch rebuildResult.type {
        case .success(let timeTaken):
            let seconds = max(Int(timeTaken), 1)
            let unit = seconds == 1 ? "second" : "seconds"
            return "Took \(seconds) \(unit)"
            
        case .tookTooLong:
            return "Cancelled, took too long"
            
        case .invalidRootPath:
            return "Invalid root path"
            
        case .noMatchingFiles:
            return "No matching files"
            
        case .noRootPathSet:
            return "No root path set"
            
        case .unknownError:
            return "Unknown error"
            
        case .none:
            return "No status"
        }
    }
}
