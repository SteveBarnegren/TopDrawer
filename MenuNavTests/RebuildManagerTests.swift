//
//  RebuildManagerTests.swift
//  MenuNav
//
//  Created by Steve Barnegren on 10/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import XCTest
@testable import MenuNav

class MockSettingsKeyValueStore: KeyValueStore {
    
    struct Keys {
        static let path = "path"
        static let shortenPaths = "shortenPaths"
        static let followAliases = "followAliases"
        static let refreshMinutes = "refreshMinutes"
        static let timeout = "timeout"
    }
    
    var path: String?
    var shortenPaths: Bool?
    var followAliases: Bool?
    var refreshMinutes: Int?
    var timeout: Int?
    
    init(path: String?, shortenPaths: Bool?, followAliases: Bool?, refreshMinutes: Int?, timeout: Int?) {
        self.path = path
        self.shortenPaths = shortenPaths
        self.followAliases = followAliases
        self.refreshMinutes = refreshMinutes
        self.timeout = timeout
    }
    
    func set(value: Any, forKey key: String) {
        fatalError("Not Implemented")
    }
    
    func value(forKey key: String) -> Any? {
        fatalError("Not implemented")
    }
    
    func set(bool: Bool, forKey key: String) {
        switch key {
        case Keys.shortenPaths: shortenPaths = bool
        case Keys.followAliases: followAliases = bool
        default: fatalError("Unknown settings key: \(key)")
        }
    }
    
    func bool(forKey key: String) -> Bool? {
        switch key {
        case Keys.shortenPaths: return shortenPaths
        case Keys.followAliases: return followAliases
        default: fatalError("Unknown settings key: \(key)")
        }
    }
    
    func set(string: String, forKey key: String) {
        switch key {
        case Keys.path: path = string
        default: fatalError("Unknown settings key: \(key)")
        }
    }
    
    func string(forKey key: String) -> String? {
        switch key {
        case Keys.path: return path
        default: fatalError("Unknown settings key: \(key)")
        }    }
    
    func set(int: Int, forKey key: String) {
        switch key {
        case Keys.refreshMinutes: refreshMinutes = int
        case Keys.timeout: timeout = int
        default: fatalError("Unknown settings key: \(key)")
        }
    }
    
    func int(forKey key: String) -> Int? {
        switch key {
        case Keys.refreshMinutes: return refreshMinutes
        case Keys.timeout: return timeout
        default: fatalError("Unknown settings key: \(key)")
        }

    }
}

class MockRebuildManagerListener: RebuildManagerListener {
    
    var onRebuildManagerDidChangeState: (RebuildManager.State) -> Void = { _ in }
    
    func rebuildManagerDidChangeState(state: RebuildManager.State) {
        onRebuildManagerDidChangeState(state)
    }
}
/*
class MockRebuildManagerListener: RebuildManagerListener {
    
    enum Event {
        case stateChange(RebuildManager.State)
        case didRebuild
        case noPathSet
    }
    
    var events = [Event]()
    var changeStateCallback: () -> Void = {}
    var didRebuildCallback: () -> Void = {}
    var noPathSetCallback: () -> Void = {}

    func rebuildManagerDidChangeState(state: RebuildManager.State) {
        events.append(.stateChange(state))
        changeStateCallback()
    }
    
    func rebuildManagerDidRebuild(directory: Directory) {
        events.append(.didRebuild)
        didRebuildCallback()
    }
    
    func rebuildManagerDidFailRebuildDueToNoRootPathSet() {
        events.append(.noPathSet)
        noPathSetCallback()
    }
}
*/
class RebuildManagerTests: XCTestCase {
    
    // MARK: - Helpers
    
    func makeMockFileReader() -> FileReader {
        return MockFileReader(
            .folder( "Root", [
                .folder( "Photos", [
                    .file("dog.png"),
                    .file("cat.png")
                    ])
                ])
        )
    }
    
    func makeMatchingRulesKeyValueStore() -> KeyValueStore {
        
        let keyValueStore = DictionaryKeyValueStore()
        let ruleLoader = RuleLoader<FileRule>(keyValueStore: keyValueStore)
        let rule = FileRule(conditions: [.ext(.matching("png"))])
        ruleLoader.add(rule: rule)
        return keyValueStore
    }
    
    func makeMockSettings(path: String?,
                          shortenPaths: Bool?,
                          followAliases: Bool?,
                          refreshMinutes: Int?,
                          timeout: Int?) -> Settings {
        
        let mockKeyValueStore = MockSettingsKeyValueStore(path: path,
                                                          shortenPaths: shortenPaths,
                                                          followAliases: followAliases,
                                                          refreshMinutes: refreshMinutes,
                                                          timeout: timeout)
        return Settings(keyValueStore: mockKeyValueStore)
    }
    
    // MARK: - Tests
    /*
    func testRebuildManagerRebuildCallback() {
        
        let e = expectation(description: "RebuildManager calls didRebuild callback")
        
        let mockSettings = makeMockSettings(path: "Root",
                                            shortenPaths: false,
                                            followAliases: false,
                                            refreshMinutes: 10,
                                            timeout: 10)
        
        let rebuildManager = RebuildManager(settings: mockSettings,
                                            fileReader: makeMockFileReader(),
                                            rulesKeyValueStore: makeMatchingRulesKeyValueStore(),
                                            timerType: MockTimerBenign.self)
        
        let mockListener = MockRebuildManagerListener()
        mockListener.didRebuildCallback = {
            e.fulfill()
        }
        
        rebuildManager.addListener(mockListener)
        rebuildManager.needsRebuild = true        
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Expected didRebuild to be called \(error)")
            }
        }
    }
 */
    
    func testRebuildManagerRebuildSuccessCallback() {
        
        let e = expectation(description: "RebuildManager calls didRebuild callback")
        
        let mockSettings = makeMockSettings(path: "Root",
                                            shortenPaths: false,
                                            followAliases: false,
                                            refreshMinutes: 10,
                                            timeout: 10)
        
        let rebuildManager = RebuildManager(settings: mockSettings,
                                            fileReader: makeMockFileReader(),
                                            rulesKeyValueStore: makeMatchingRulesKeyValueStore(),
                                            timerType: MockTimerBenign.self)
        
        let mockListener = MockRebuildManagerListener()
        mockListener.onRebuildManagerDidChangeState = { state in

            if state == .idle, case .success = rebuildManager.lastResults.type {
                e.fulfill()
            }
        }
        
        rebuildManager.addListener(mockListener)
        rebuildManager.needsRebuild = true
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Expected didRebuild to be called \(error)")
            }
        }
    }
    
    func testRebuildManagerNoPathCallback() {
        
        let e = expectation(description: "RebuildManager calls noPath callback")
        
        let mockSettings = makeMockSettings(path: nil,
                                            shortenPaths: false,
                                            followAliases: false,
                                            refreshMinutes: 10,
                                            timeout: 10)
        
        let rebuildManager = RebuildManager(settings: mockSettings,
                                            fileReader: makeMockFileReader(),
                                            rulesKeyValueStore: makeMatchingRulesKeyValueStore(),
                                            timerType: MockTimerBenign.self)
        
        let mockListener = MockRebuildManagerListener()
        mockListener.onRebuildManagerDidChangeState = { state in
            
            if state == .idle, case .noRootPathSet = rebuildManager.lastResults.type {
                e.fulfill()
            }
        }
        
        rebuildManager.addListener(mockListener)
        rebuildManager.needsRebuild = true
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Expected no path callback to be called \(error)")
            }
        }
    }
    /*
    func testRebuildManagerRebuildCancelsInProgressBuild() {
        
        let asycTime = 2.0
        
        let e = expectation(description: "RebuildManager calls didRebuild callback")
        
        var numCallbacks = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + asycTime) {
            XCTAssertEqual(numCallbacks, 1)
            if numCallbacks == 1 {
                e.fulfill()
            }
        }
        
        let mockSettings = makeMockSettings(path: "Root", shortenPaths: false, followAliases: false, refreshMinutes: 10)
        let rebuildManager = RebuildManager(settings: mockSettings,
                                            fileReader: makeMockFileReader(),
                                            rulesKeyValueStore: makeMatchingRulesKeyValueStore())
        
        let mockListener = MockRebuildManagerListener()
        mockListener.didRebuildCallback = {
            numCallbacks += 1;
        }
        
        rebuildManager.addListener(mockListener)
        rebuildManager.needsRebuild = true
        rebuildManager.needsRebuild = true

        waitForExpectations(timeout: asycTime + 0.5) { error in
            if let error = error {
                XCTFail("Expected didRebuild to be called only once \(error)")
            }
        }
    }
 */
}
