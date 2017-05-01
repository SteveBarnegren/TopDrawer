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
    @IBOutlet weak private var tableView: NSTableView!

    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // IconImageView
        iconImageView.image = NSImage(named: "AppIcon")
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Update UI
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
    
    @IBAction func addFileTypeButtonPressed(sender: NSButton){
        print("Add file type button pressed")
        
        let title = "Add a file extension"
        let button = "Add"
        
        let input = TextInputViewController.create(title: title, button: button) {
            _ in
        }
        
        addChildViewController(input)
        view.addSubview(input.view)
        input.view.pinToSuperviewEdges()
    }
    
    // MARK: - Update
    
    func updatePathLabel() {
        
        let text = Settings.path ?? "No path set"
        textField.stringValue = text
    }
    
    func updateOpenAtLoginCheckbox() {
        
        print("State: \(Settings.openAtLogin))")
        
        openAtLoginCheckbox.state = Settings.openAtLogin ? NSOnState : NSOffState
    }
}

extension ViewController : NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = "FileExtensionCell"
        
        guard let cell = tableView.make(withIdentifier: identifier, owner: nil) as? NSTableCellView else {
            fatalError("Unable to create table cell")
        }
        
        cell.textField?.stringValue = "This is a test"
        cell.imageView?.image = nil
        
        return cell
    }
}

extension ViewController : NSTableViewDelegate {
}

