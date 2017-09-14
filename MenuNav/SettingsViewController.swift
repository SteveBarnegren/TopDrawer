//
//  SettingsViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 15/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var followAliasesButton: NSButton!
    @IBOutlet weak fileprivate var shortenPathsButton: NSButton!
    @IBOutlet weak fileprivate var openAtLoginButton: NSButton!
    @IBOutlet weak fileprivate var refreshIntervalDropdown: NSPopUpButton!

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
        let intervals = [5, 10, 15, 20, 30, 45, 60]
        intervals.forEach{
            refreshIntervalDropdown.addItem(withTitle: "\($0)")
        }
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
}
