//
//  SettingsViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 15/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import AttributedStringBuilder

class SettingsViewController: NSViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var followAliasesButton: NSButton!
    @IBOutlet weak fileprivate var shortenPathsButton: NSButton!
    @IBOutlet weak fileprivate var openAtLoginButton: NSButton!
    @IBOutlet weak fileprivate var refreshIntervalDropdown: NSPopUpButton!
    @IBOutlet weak fileprivate var timeoutIntervalDropdown: NSPopUpButton!
    @IBOutlet weak fileprivate var lastRebuildTimeLabel: NSTextField!
    @IBOutlet weak fileprivate var timeTakenLabel: NSTextField!
    @IBOutlet weak fileprivate var gitHubButton: NSButton!
    
    let rebuildManager: RebuildManager
    
    let refreshIntervals: [Interval] = [
        .minutes(5),
        .minutes(10),
        .minutes(15),
        .minutes(20),
        .minutes(30),
        .minutes(45),
        .minutes(60),
        .never
    ]
    
    let timeoutIntervals: [Interval] = [
        .seconds(15),
        .seconds(30),
        .seconds(45),
        .minutes(1),
        .minutes(2),
        .minutes(3),
        .never
    ]
    
    init(rebuildManager: RebuildManager) {
        self.rebuildManager = rebuildManager
        super.init(nibName: NSNib.Name(rawValue: "SettingsViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Follow aliases button
        followAliasesButton.state = Settings.shared.followAliases.value ? .on : .off
        
        // Shorten Paths button
        shortenPathsButton.state = Settings.shared.shortenPaths.value ? .on : .off
        
        // Open at login button
        openAtLoginButton.state = Bundle.main.isLoginItem() ? .on : .off
        
        // Rebuild interval Dropdown
        setupRefreshIntervalDropdown()
        
        // Timeout interval dropdown
        setupTimeoutIntervalDropdown()
        
        // Setup github button
        setupGitHubButton()
        
        // Observe Rebuild Manager
        rebuildManager.addListener(self)
    }
    
    func setupRefreshIntervalDropdown() {
        refreshIntervalDropdown.removeAllItems()
        refreshIntervals.forEach {
            refreshIntervalDropdown.addItem(withTitle: $0.title)
        }
        
        let index = refreshIntervals.index { Int($0.minutesValue) == Settings.shared.refreshMinutes.value }
            ?? refreshIntervals.count - 1
        
        refreshIntervalDropdown.selectItem(at: index)
    }
    
    func setupTimeoutIntervalDropdown() {
        timeoutIntervalDropdown.removeAllItems()
        timeoutIntervals.forEach {
            timeoutIntervalDropdown.addItem(withTitle: $0.title)
        }
        
        let index = timeoutIntervals.index { Int($0.secondsValue) == Settings.shared.timeout.value }
            ?? timeoutIntervals.count - 1
        
        timeoutIntervalDropdown.selectItem(at: index)
    }
    
    func setupGitHubButton() {
        
        let text = gitHubButton.title
        let font = gitHubButton.font!
        let color = NSColor.blue
        
        let attributedString =
            AttributedStringBuilder()
            .text(text, attributes: [.font(font), .textColor(color)])
            .attributedString
        
        gitHubButton.attributedTitle = attributedString
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateTimeTakenLabel()
        updateLastRebuildTimeLabel()
    }
    
    // MARK: - Update UI
    
    fileprivate func updateLastRebuildTimeLabel() {
        
        let lastResult = rebuildManager.lastResults
        
        if case .none = lastResult {
            lastRebuildTimeLabel.stringValue = ""
        } else {
            let formatter = RebuildResultsFormatter()
            lastRebuildTimeLabel.stringValue = formatter.lastRefreshString(fromResult: lastResult)
        }
        
    }
    
    fileprivate func updateTimeTakenLabel() {
        
        let lastResult = rebuildManager.lastResults
        
        if case .none = lastResult {
            timeTakenLabel.stringValue = ""
        } else {
            let formatter = RebuildResultsFormatter()
            timeTakenLabel.stringValue = formatter.lastStatusString(fromResult: lastResult)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func followAliasesButtonPressed(sender: NSButton) {
        let isOn = followAliasesButton.state == .on
        Settings.shared.followAliases.value = isOn
    }
    
    @IBAction private func shortenPathsButtonPressed(sender: NSButton) {
        let isOn = shortenPathsButton.state == .on
        Settings.shared.shortenPaths.value = isOn
    }
    
    @IBAction private func openAtLoginButtonPressed(sender: NSButton) {
        let isOn = openAtLoginButton.state == .on
        
        if isOn {
            Bundle.main.addToLoginItems()
        } else {
            Bundle.main.removeFromLoginItems()
        }
    }
    
    @IBAction private func refreshIntervalDropdownValueChanged(sender: NSPopUpButton) {
        
        guard let interval = refreshIntervals.first(where: {
            $0.title == refreshIntervalDropdown.selectedItem?.title
        }) else {
            fatalError("Unable to get interval from dropdown choice")
        }
        
        Settings.shared.refreshMinutes.value = Int(interval.minutesValue)
    }
    
    @IBAction private func timeoutIntervalDropdownValueChanged(sender: NSPopUpButton) {
        
        guard let interval = timeoutIntervals.first(where: {
            $0.title == timeoutIntervalDropdown.selectedItem?.title
        }) else {
            fatalError("Unable to get interval from dropdown choice")
        }
        
        Settings.shared.timeout.value = Int(interval.secondsValue)
    }
    
    @IBAction private func openGitHubPageButtonPressed(sender: NSButton){
        if let url = URL(string: "https://github.com/SteveBarnegren/MenuNav") {
            NSWorkspace.shared.open(url)
        }
    }
}

extension SettingsViewController: RebuildManagerListener {
    
    func rebuildManagerDidRebuild(directory: Directory) {
        updateTimeTakenLabel()
        updateLastRebuildTimeLabel()
    }
    
    func rebuildManagerDidChangeState(state: RebuildManager.State) {
        updateTimeTakenLabel()
        updateLastRebuildTimeLabel()
    }
}
