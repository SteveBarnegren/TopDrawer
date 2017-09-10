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
    @IBOutlet weak fileprivate var refreshIntervalDropdown: NSPopUpButton!
    
    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Follow aliases button
        followAliasesButton.state = Settings.shared.followAliases.value ? NSOnState : NSOffState
        
        // Shorten Paths button
        shortenPathsButton.state = Settings.shared.shortenPaths.value ? NSOnState : NSOffState
        
        // Rebuild Interval Popup
        refreshIntervalDropdown.removeAllItems()
        let intervals = [5, 10, 15, 20, 30, 45, 60]
        intervals.forEach{
            refreshIntervalDropdown.addItem(withTitle: "\($0)")
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func followAliasesButtonPressed(sender: NSButton){
        let isOn = followAliasesButton.state == NSOnState
        Settings.shared.followAliases.value = isOn
    }
    
    @IBAction private func shortenPathsButtonPressed(sender: NSButton){
        let isOn = shortenPathsButton.state == NSOnState
        Settings.shared.shortenPaths.value = isOn
    }
}
