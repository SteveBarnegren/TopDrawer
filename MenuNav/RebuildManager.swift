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
    
    var isRebuilding = false {
        didSet{
            if isRebuilding == true {
                //showRebuldingMenu() //!
            }
            else{
                print("STOP")
            }
        }
    }
    
    var needsRebuild = false {
        didSet{
            if needsRebuild && !isRebuilding {
                buildMenuIfNeeded()
            }
            else if needsRebuild && isRebuilding {
                workItem!.cancel()
            }
        }
    }
    
    var workItem: DispatchWorkItem?
    
    let listeners = WeakArray<RebuildManagerListener>()
    
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
        isRebuilding = true
        
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
                    self?.isRebuilding = false
                    self!.buildMenuIfNeeded()
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    print("Finished Building menu")
                    self?.isRebuilding = false
                    self?.listeners.objects.forEach{ $0.rebuildManagerDidFailRebuildDueToNoRootPathSet() }
                })
                return
            }
            
            guard let item = self?.workItem else {
                self?.isRebuilding = false
                return
            }
            
            if item.isCancelled {
                self?.isRebuilding = false
                self!.buildMenuIfNeeded()
                return
            }
            
            DispatchQueue.main.async(execute: {
                print("Finished Building menu")
                self?.isRebuilding = false
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

}
