//
//  RebuildManager.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

protocol RebuildManagerListener: class {
    func rebuildManagerDidChangeState(state: RebuildManager.State)
    func rebuildManagerDidRebuild(directory: Directory) // Optional
    func rebuildManagerDidFailRebuildDueToNoRootPathSet() // Optional
}

extension RebuildManagerListener {
    func rebuildManagerDidRebuild(directory: Directory) {}
    func rebuildManagerDidFailRebuildDueToNoRootPathSet(){}
}

class RebuildManager {
    
    // MARK: - Types
    enum State {
        case idle
        case rebuilding
    }
    
    // MARK: - Properties
    
    static let shared = RebuildManager()
    
    var state = State.idle {
        didSet{
            switch state {
            case .idle:
                startRefreshTimer()
            case .rebuilding:
                stopRefreshTimer()
            }
            listeners.objects.forEach{ $0.rebuildManagerDidChangeState(state: state) }
        }
    }
    
    var needsRebuild = false {
        didSet{
            if needsRebuild {
                switch state {
                case .idle:
                    buildMenuIfNeeded()
                case .rebuilding:
                    workItem!.cancel()
                }
            }
        }
    }
    
    var workItem: DispatchWorkItem?
    
    let listeners = WeakArray<RebuildManagerListener>()
    
    var refreshTimer: Timer?
    
    // MARK: - Build menu
    
    func buildMenuIfNeeded() {
        if needsRebuild {
            needsRebuild = false
            buildMenu()
        }
    }
    
    func buildMenu() {
        
        print("Rebuilding menu")
        self.workItem = nil
        state = .rebuilding
        
        // Get the file structure
        var options = FileStructureBuilder.Options()
        
        if Settings.shortenPaths {
            options.update(with: .shortenPaths)
        }
        
        if Settings.followAliases {
            options.update(with: .followAliases)
        }
        
        let builder = FileStructureBuilder(fileReader: FileManager.default,
                                           fileRules: FileRule.ruleLoader.rules,
                                           folderRules: FolderRule.ruleLoader.rules,
                                           options: options)
        
        guard let path = Settings.path else {
            listeners.objects.forEach{ $0.rebuildManagerDidFailRebuildDueToNoRootPathSet() }
            return
        }
        
        workItem = DispatchWorkItem { [weak self] in
            
            builder.isCancelledHandler = {
                if let item = self?.workItem, item.isCancelled {
                    print("Cancelled building menu")
                    return true
                }
                else{
                    return false
                }
            }
            
            guard let rootDirectory = builder.buildFileSystemStructure(atPath: path) else {
                
                guard let item = self?.workItem else {
                    return
                }
                
                if item.isCancelled {
                    self?.state = .idle
                    self?.buildMenuIfNeeded()
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    print("Finished Building menu")
                    self?.state = .idle
                    self?.listeners.objects.forEach{ $0.rebuildManagerDidFailRebuildDueToNoRootPathSet() }
                })
                return
            }
            
            guard let item = self?.workItem else {
                self?.state = .idle
                return
            }
            
            if item.isCancelled {
                self?.state = .idle
                self?.buildMenuIfNeeded()
                return
            }
            
            DispatchQueue.main.async(execute: {
                print("Finished Building menu")
                self?.state = .idle
                self?.listeners.objects.forEach{
                    $0.rebuildManagerDidRebuild(directory: rootDirectory)
                }
            })
        }
        
        DispatchQueue.global().async(execute: workItem!)
        
    }
    
    // MARK: - Manage Listeners
    
    func addListener(_ listener: RebuildManagerListener) {
        listeners.append(listener)
    }
    
    func removeListener(_ listener: RebuildManagerListener) {
        listeners.remove(listener)
    }
    
    // MARK: - Refrash Timer
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func startRefreshTimer() {
        
        stopRefreshTimer()
        
        let seconds = TimeInterval(Settings.refreshMinutes * 60)
        
        refreshTimer = Timer(timeInterval: seconds,
                             target: self,
                             selector: #selector(refreshTimerFired),
                             userInfo: nil,
                             repeats: false)
        
        // Increased tolerance allows mac os to better manage power usage
        refreshTimer?.tolerance = seconds * 0.2
        
        let runLoop = RunLoop.current
        runLoop.add(refreshTimer!, forMode: .commonModes)
    }
    
    @objc private func refreshTimerFired() {
        needsRebuild = true
    }

}
