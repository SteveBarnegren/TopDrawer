//
//  ViewController.swift
//  MenuNav
//
//  Created by Steven Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak private var textField: NSTextField!
    @IBOutlet weak private var button: NSButton!
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak private var openAtLoginCheckbox: NSButton!

    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        iconImageView.image = NSImage(named: "AppIcon")
        
        updatePathLabel()
        updateOpenAtLoginCheckbox()
    }
    
    // MARK: - Actions
    
    @IBAction func chooseFolderButtonPressed(sender: NSButton){
        print("Choose folder button pressed")
        
        let openDialogue = NSOpenPanel()
        
        openDialogue.title = "Choose a folder"
        openDialogue.showsResizeIndicator = true
        openDialogue.showsHiddenFiles = false
        openDialogue.canChooseDirectories = true
        openDialogue.canCreateDirectories = false
        openDialogue.allowedFileTypes = nil
        
        if openDialogue.runModal() == NSModalResponseOK {
            
            guard let result = openDialogue.url else {
                return
            }
            
            let path = result.path
            Settings.path = path
            (NSApp.delegate as? AppDelegate)?.rebuild()
        }
    }
    
    @IBAction func openAtLoginCheckboxPressed(sender: NSButton){
        print("Open at login checkbox pressed")
        
        let isOn = (openAtLoginCheckbox.state == NSOnState)
        Settings.openAtLogin = isOn
    }
    
    // MARK: - Update
    
    func updatePathLabel() {
        
        let text = Settings.path ?? "No path set"
        textField.stringValue = text
    }
    
    func updateOpenAtLoginCheckbox() {
        
        openAtLoginCheckbox.state = Settings.openAtLogin ? NSOnState : NSOffState
    }
}

