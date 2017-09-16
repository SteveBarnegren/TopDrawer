//
//  SettingsViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 15/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    enum Interval {
        case minutes(Int)
        case never
        
        var title: String {
            switch self {
            case let .minutes(m):
                return "\(m)"
            case .never:
                return "Never"
            }
        }
        
        var value: Int {
            switch self {
            case let .minutes(m):
                return m
            case .never:
                return -1
            }
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var followAliasesButton: NSButton!
    @IBOutlet weak fileprivate var shortenPathsButton: NSButton!
    @IBOutlet weak fileprivate var openAtLoginButton: NSButton!
    @IBOutlet weak fileprivate var refreshIntervalDropdown: NSPopUpButton!
        
        let intervals: [Interval] = [
            .minutes(5),
            .minutes(10),
            .minutes(15),
            .minutes(20),
            .minutes(30),
            .minutes(45),
            .minutes(60),
            .never
        ]

    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Follow aliases button
        followAliasesButton.state = Settings.shared.followAliases.value ? .on : .off
        
        // Shorten Paths button
        shortenPathsButton.state = Settings.shared.shortenPaths.value ? .on : .off
        
        // Open at login button
        openAtLoginButton.state = Bundle.main.isLoginItem() ? .on : .off
        
        // Rebuild Interval Popup
        refreshIntervalDropdown.removeAllItems()
        intervals.forEach{
            refreshIntervalDropdown.addItem(withTitle: $0.title)
        }
        
        let index = intervals.index(where: { $0.value == Settings.shared.refreshMinutes.value }) ?? intervals.count - 1
        refreshIntervalDropdown.selectItem(at: index)
    }
    
    // MARK: - Actions
    
    @IBAction private func followAliasesButtonPressed(sender: NSButton){
        let isOn = followAliasesButton.state == .on
        Settings.shared.followAliases.value = isOn
    }
    
    @IBAction private func shortenPathsButtonPressed(sender: NSButton){
        let isOn = shortenPathsButton.state == .on
        Settings.shared.shortenPaths.value = isOn
    }
    
    @IBAction private func openAtLoginButtonPressed(sender: NSButton){
        let isOn = openAtLoginButton.state == .on
        
        if isOn {
            Bundle.main.addToLoginItems()
        } else {
            Bundle.main.removeFromLoginItems()
        }
    }
    
    @IBAction private func refreshIntervalDropdownValueChanged(sender: NSPopUpButton){
        
        guard let interval = intervals.first(where: { $0.title == refreshIntervalDropdown.selectedItem?.title }) else {
            fatalError("Unable to get interval from dropdown choice")
        }
        
        Settings.shared.refreshMinutes.value = interval.value
    }
}
