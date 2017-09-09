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
    
    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Follow aliases button
        followAliasesButton.state = Settings.followAliases ? NSOnState : NSOffState
        
        // Shorten Paths button
        shortenPathsButton.state = Settings.shortenPaths ? NSOnState : NSOffState
    }
    
    // MARK: - Actions
    
    @IBAction private func followAliasesButtonPressed(sender: NSButton){
        let isOn = followAliasesButton.state == NSOnState
        Settings.followAliases = isOn
        rebuild()
    }
    
    @IBAction private func shortenPathsButtonPressed(sender: NSButton){
        let isOn = shortenPathsButton.state == NSOnState
        Settings.shortenPaths = isOn
        rebuild()
    }
    
    // MARK: - Rebuild
    
    func rebuild() {
        RebuildManager.shared.needsRebuild = true
    }
    
}
