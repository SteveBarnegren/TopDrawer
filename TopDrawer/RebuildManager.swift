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
}

extension RebuildManagerListener {
    func rebuildManagerDidChangeState(state: RebuildManager.State) {}
}

class RebuildManager {
    
    // MARK: - Types
    
    enum State {
        case idle
        case rebuilding
    }
    
    enum ResultType {
        case none
        case success(timeTaken: TimeInterval)
        case tookTooLong
        case noRootPathSet
        case invalidRootPath
        case noMatchingFiles
        case unknownError
    }
    
    struct Result {
        let type: ResultType
        let date: Date
        let menuModel: MenuModel?
    }
    
    // MARK: - Properties
    
    private(set) var state = State.idle {
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
    
    var lastResults = Result(type: .none, date: Date(), menuModel: nil)
    
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
        settings.enableTerminalHere.add(changeObserver: self, selector: #selector(enableTerminalHereSettingChanged))
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
                                           options: options,
                                           iconProvider: WorkspaceIconProvider())
        
        let path = settings.path.value
        
        if path.count == 0 {
            rebuildCompleted(resultType: .noRootPathSet, directory: nil)
            return
        }

        // Create work item
        workItem = DispatchWorkItem { [weak self] in
            
            builder.isCancelledHandler = {
                if let item = self?.workItem, item.isCancelled {
                    print("Cancelled building menu")
                    return true
                } else {
                    return false
                }
            }
            
            let rootDirectory: Directory
            do {
                rootDirectory = try builder.buildFileSystemStructure(atPath: path)
            } catch FileStructureBuilderError.cancelled {
                DispatchQueue.main.async(execute: {
                    self?.state = .idle
                    self?.buildMenuIfNeeded()
                })
                return 
            } catch FileStructureBuilderError.invalidRootPath {
                DispatchQueue.main.async(execute: {
                    self?.rebuildCompleted(resultType: .invalidRootPath, directory: nil)
                })
                return
            } catch FileStructureBuilderError.noMatchingFiles {
                DispatchQueue.main.async(execute: {
                    self?.rebuildCompleted(resultType: .noMatchingFiles, directory: nil)
                })
                return
            } catch {
                DispatchQueue.main.async(execute: {
                    self?.rebuildCompleted(resultType: .unknownError, directory: nil)
                })
                return
            }
        
            DispatchQueue.main.async(execute: {
                
                guard let item = self?.workItem else {
                    self?.rebuildCompleted(resultType: .unknownError, directory: nil)
                    return
                }
                
                if item.isCancelled {
                    self?.rebuildCompleted(resultType: .tookTooLong, directory: nil)
                    self?.buildMenuIfNeeded()
                    return
                }
                
                print("Finished Building menu")
                self?.rebuildCompleted(
                    resultType: .success(timeTaken: CFAbsoluteTimeGetCurrent() - self!.rebuildStartTime),
                    directory: rootDirectory
                )
                
            })
        }
    
        DispatchQueue.global().async(execute: workItem!)
    
    }
    
    func rebuildCompleted(resultType: ResultType, directory: Directory?) {
        lastResults = Result(type: resultType,
                             date: Date(),
                             menuModel: directory?.asMenuItemModel() ?? lastResults.menuModel)
        self.state = .idle
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
            self.rebuildCompleted(resultType: .tookTooLong, directory: nil)
        }
    }

    // MARK: - Settings Observers

    @objc private func followAliasesSettingChanged() {
        needsRebuild = true
    }
    
    @objc private func enableTerminalHereSettingChanged() {
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
