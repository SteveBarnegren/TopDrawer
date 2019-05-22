//
//  SettingsViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 15/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import AttributedStringBuilder
import ServiceManagement

struct SettingsIntervalChoices {
    
    static let refreshIntervals: [Interval] = [
        .minutes(5),
        .minutes(10),
        .minutes(15),
        .minutes(20),
        .minutes(30),
        .minutes(45),
        .minutes(60),
        .never
    ]
    
    static let timeoutIntervals: [Interval] = [
        .seconds(15),
        .seconds(30),
        .seconds(45),
        .minutes(1),
        .minutes(2),
        .minutes(3),
        .never
    ]
}

class SettingsViewController: NSViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var followAliasesButton: NSButton!
    @IBOutlet weak fileprivate var shortenPathsButton: NSButton!
    @IBOutlet weak fileprivate var openAtLoginButton: NSButton!
    @IBOutlet weak fileprivate var enableTerminalHereButton: NSButton!
    @IBOutlet weak fileprivate var refreshIntervalDropdown: NSPopUpButton!
    @IBOutlet weak fileprivate var timeoutIntervalDropdown: NSPopUpButton!
    @IBOutlet weak fileprivate var lastRebuildTimeLabel: NSTextField!
    @IBOutlet weak fileprivate var timeTakenLabel: NSTextField!
    @IBOutlet weak fileprivate var gitHubButton: NSButton!
    @IBOutlet weak fileprivate var quitAndRemoveDataButton: NSButton!
    
    let rebuildManager: RebuildManager
    
    init(rebuildManager: RebuildManager) {
        self.rebuildManager = rebuildManager
        super.init(nibName: "SettingsViewController", bundle: nil)
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
        openAtLoginButton.state = Settings.shared.launchAtLogin.value ? .on : .off
        
        // Enable terminal here button
        enableTerminalHereButton.state = Settings.shared.enableTerminalHere.value ? .on : .off
        
        // Rebuild interval Dropdown
        setupRefreshIntervalDropdown()
        
        // Timeout interval dropdown
        setupTimeoutIntervalDropdown()
        
        // Setup github button
        setupGitHubButton()
        
        // Observe Rebuild Manager
        rebuildManager.addListener(self)
        
        #if !DEBUG
        quitAndRemoveDataButton.isHidden = true
        #endif
    }
    
    // swiftlint:disable line_length
    func setupRefreshIntervalDropdown() {
        refreshIntervalDropdown.removeAllItems()
        SettingsIntervalChoices.refreshIntervals.forEach {
            refreshIntervalDropdown.addItem(withTitle: $0.title)
        }
        
        let index =
            SettingsIntervalChoices.refreshIntervals.index { Int($0.minutesValue) == Settings.shared.refreshMinutes.value }
                ?? SettingsIntervalChoices.refreshIntervals.count - 1
        
        refreshIntervalDropdown.selectItem(at: index)
    }
    
    func setupTimeoutIntervalDropdown() {
        timeoutIntervalDropdown.removeAllItems()
        SettingsIntervalChoices.timeoutIntervals.forEach {
            timeoutIntervalDropdown.addItem(withTitle: $0.title)
        }
        
        let index =
            SettingsIntervalChoices.timeoutIntervals.index { Int($0.secondsValue) == Settings.shared.timeout.value }
                ?? SettingsIntervalChoices.timeoutIntervals.count - 1
        
        timeoutIntervalDropdown.selectItem(at: index)
    }
    // swiftlint:enable line_length
    
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
        
        if case .none = lastResult.type {
            lastRebuildTimeLabel.stringValue = ""
        } else {
            let formatter = RebuildResultsFormatter()
            lastRebuildTimeLabel.stringValue = formatter.lastRefreshString(fromResult: lastResult)
        }
        
    }
    
    fileprivate func updateTimeTakenLabel() {
        
        let lastResult = rebuildManager.lastResults
        
        if case .none = lastResult.type {
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
        Settings.shared.launchAtLogin.value = isOn
        SMLoginItemSetEnabled(AppDelegate.launcherAppId as CFString, isOn)
    }
    
    @IBAction private func enableTerminalHereButtonPressed(sender: NSButton) {
        let isOn = enableTerminalHereButton.state == .on
        Settings.shared.enableTerminalHere.value = isOn
    }
    
    @IBAction private func refreshIntervalDropdownValueChanged(sender: NSPopUpButton) {
        
        guard let interval = SettingsIntervalChoices.refreshIntervals.first(where: {
            $0.title == refreshIntervalDropdown.selectedItem?.title
        }) else {
            fatalError("Unable to get interval from dropdown choice")
        }
        
        Settings.shared.refreshMinutes.value = Int(interval.minutesValue)
    }
    
    @IBAction private func timeoutIntervalDropdownValueChanged(sender: NSPopUpButton) {
        
        guard let interval = SettingsIntervalChoices.timeoutIntervals.first(where: {
            $0.title == timeoutIntervalDropdown.selectedItem?.title
        }) else {
            fatalError("Unable to get interval from dropdown choice")
        }
        
        Settings.shared.timeout.value = Int(interval.secondsValue)
    }
    
    @IBAction private func openGitHubPageButtonPressed(sender: NSButton) {
        if let url = URL(string: "https://github.com/SteveBarnegren/TopDrawer") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction private func showContributorsButtonPressed(sender: NSButton) {
        if let url = URL(string: "https://github.com/SteveBarnegren/TopDrawer/graphs/contributors") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction private func quitAndRemoveDataButtonPressed(sender: NSButton) {
        
        let userDefaults = UserDefaults.standard
        for key in userDefaults.dictionaryRepresentation().keys where key.contains(subString: "debug") {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
        NSApp.terminate(self)
    }
}

extension SettingsViewController: RebuildManagerListener {
    
    func rebuildManagerDidChangeState(state: RebuildManager.State) {
        updateTimeTakenLabel()
        updateLastRebuildTimeLabel()
    }
}
