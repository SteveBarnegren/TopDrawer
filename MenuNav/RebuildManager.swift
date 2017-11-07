//
//  RebuildManager.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

protocol RebuildManagerListener: class {
    func rebuildManagerDidChangeState(state: RebuildManager.State) // Optional
    func rebuildManagerDidRebuild(directory: Directory) // Optional
    func rebuildManagerDidFailRebuildDueToNoRootPathSet() // Optional
}

extension RebuildManagerListener {
    func rebuildManagerDidChangeState(state: RebuildManager.State) {}
    func rebuildManagerDidRebuild(directory: Directory) {}
    func rebuildManagerDidFailRebuildDueToNoRootPathSet() {}
}

class RebuildManager {
        
    // MARK: - Types
    
    enum State {
        case idle
        case rebuilding
    }
    
    enum Result {
        case none
        case success(timeTaken: TimeInterval, date: Date)
        case tookTooLong(date: Date)
    }
    
    // MARK: - Properties
        
    private var state = State.idle {
        didSet {
            switch state {
            case .idle:
                startRefreshTimer()
                stopTimeoutTimer()
            case .rebuilding:
                stopRefreshTimer()
                startTimeoutTimer()
            }
            listeners.objects.forEach { $0.rebuildManagerDidChangeState(state: state) }
        }
    }
    
    var needsRebuild = false {
        didSet {
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
    
    private var workItem: DispatchWorkItem?
    
    private let listeners = WeakArray<RebuildManagerListener>()
    
    private let timerType: Timer.Type
    private var refreshTimer: Timer?
    private var timeoutTimer: Timer?
    private let settings: Settings
    private let fileReader: FileReader
    private let rulesKeyValueStore: KeyValueStore
    private var rebuildStartTime = CFAbsoluteTime(0)
    
    var lastResults = Result.none
    
    // MARK: - Init
    
    convenience init() {
        self.init(settings: Settings.shared,
                  fileReader: FileManager.default,
                  rulesKeyValueStore: UserPreferences(),
                  timerType: NSTimerBasedTimer.self)
    }
    
    init(settings: Settings,
         fileReader: FileReader,
         rulesKeyValueStore: KeyValueStore,
         timerType: Timer.Type) {
        
        self.settings = settings
        self.fileReader = fileReader
        self.rulesKeyValueStore = rulesKeyValueStore
        self.timerType = timerType

        // Observe settings
        settings.path.add(changeObserver: self, selector: #selector(pathSettingChanged))
        settings.followAliases.add(changeObserver: self, selector: #selector(followAliasesSettingChanged))
        settings.shortenPaths.add(changeObserver: self, selector: #selector(shortenPathsSettingChanged))
        settings.timeout.add(changeObserver: self, selector: #selector(timeoutSettingChanged))
    }
    
    // MARK: - Build menu
    
    private func buildMenuIfNeeded() {
        if needsRebuild {
            needsRebuild = false
            buildMenu()
        }
    }
    
    // swiftlint:disable function_body_length
    private func buildMenu() {
        
        rebuildStartTime = CFAbsoluteTimeGetCurrent()
        
        print("Rebuilding menu")
        self.workItem = nil
        state = .rebuilding
        
        // Get the file structure
        var options = FileStructureBuilder.Options()
        
        if settings.shortenPaths.value {
            options.update(with: .shortenPaths)
        }
        
        if settings.followAliases.value {
            options.update(with: .followAliases)
        }
        
        let fileRuleLoader = RuleLoader<FileRule>(keyValueStore: rulesKeyValueStore)
        let folderRuleLoader = RuleLoader<FolderRule>(keyValueStore: rulesKeyValueStore)
        
        let builder = FileStructureBuilder(fileReader: fileReader,
                                           fileRules: fileRuleLoader.rules,
                                           folderRules: folderRuleLoader.rules,
                                           options: options)
        
        let path = settings.path.value
        
        /*
        guard let path = settings.path.value else {
            listeners.objects.forEach{ $0.rebuildManagerDidFailRebuildDueToNoRootPathSet() }
            return
        }
 */
        workItem = DispatchWorkItem { [weak self] in
            
            builder.isCancelledHandler = {
                if let item = self?.workItem, item.isCancelled {
                    print("Cancelled building menu")
                    return true
                } else {
                    return false
                }
            }
            
            guard let rootDirectory = builder.buildFileSystemStructure(atPath: path) else {
                
                guard let item = self?.workItem else {
                    return
                }
                
                if item.isCancelled {
                    DispatchQueue.main.async(execute: {
                        self?.state = .idle
                        self?.buildMenuIfNeeded()
                        return
                    })
                }
                
                DispatchQueue.main.async(execute: {
                    print("Finished Building menu")
                    self?.state = .idle
                    self?.listeners.objects.forEach { $0.rebuildManagerDidFailRebuildDueToNoRootPathSet() }
                })
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                guard let item = self?.workItem else {
                    self?.state = .idle
                    return
                }
                
                if item.isCancelled {
                    self?.state = .idle
                    self!.lastResults = .tookTooLong(date: Date())
                    self?.buildMenuIfNeeded()
                    return
                }
                
                self!.lastResults = .success(timeTaken: CFAbsoluteTimeGetCurrent() - self!.rebuildStartTime,
                                             date: Date())
                
                print("Finished Building menu")
                self?.state = .idle
                self?.listeners.objects.forEach {
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
    
    // MARK: - Refresh Timer
    
    private func startRefreshTimer() {
        
        stopRefreshTimer()
        
        let seconds = TimeInterval(settings.refreshMinutes.value * 60)
        guard seconds > 0 else {
            return
        }
        
        refreshTimer = timerType.init(interval: seconds,
                                      target: self,
                                      selector: #selector(refreshTimerFired),
                                      repeats: false,
                                      pctTolerance: 0.2)
        
        refreshTimer?.start()
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.stop()
        refreshTimer = nil
    }
    
    @objc private func refreshTimerFired() {
        needsRebuild = true
    }
    
    // MARK: - Timeout Timer
    
    private func startTimeoutTimer() {
        
        stopTimeoutTimer()
        
        let seconds = TimeInterval(settings.timeout.value)
        
        if seconds <= 0 {
            print("No timeout")
            return
        }
        
        print("Timeout: \(seconds)")
        
        timeoutTimer = timerType.init(interval: seconds,
                                      target: self,
                                      selector: #selector(timeoutTimerFired),
                                      repeats: false,
                                      pctTolerance: 0)
        timeoutTimer?.start()
    }
    
    private func stopTimeoutTimer() {
        timeoutTimer?.stop()
        timeoutTimer = nil
    }
    
    @objc private func timeoutTimerFired() {
        if case .rebuilding = state {
            workItem!.cancel()
            self.lastResults = .tookTooLong(date: Date())
        }
    }
    
    // MARK: - Settings Observers
    
    @objc private func followAliasesSettingChanged() {
        needsRebuild = true
    }
    
    @objc private func pathSettingChanged() {
        needsRebuild = true
    }
    
    @objc private func shortenPathsSettingChanged() {
        needsRebuild = true
    }
    
    @objc private func timeoutSettingChanged() {
        needsRebuild = true
    }
}
