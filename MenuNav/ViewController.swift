//
//  ViewController.swift
//  MenuNav
//
//  Created by Steven Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak private var textField: NSTextField!
    @IBOutlet weak private var button: NSButton!
    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak fileprivate var segmentedControl: NSSegmentedControl!
    
    @IBOutlet weak fileprivate var contentView: NSView!
    fileprivate var contentViewController: NSViewController?

    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // IconImageView
        iconImageView.image = NSImage(named: "AppIcon")
        
        // Update UI
        updatePathLabel()
    
        // Show file rules content
        showFileRules()
    }
    
    // MARK: - Content view
    
    func showFileRules() {
        print("Show file rules")
        
        self.segmentedControl.selectedSegment = 0
        
        let viewModel = RulesViewModel(editRuleTitle: "Add File Rule",
                                       addConditionPrompt: "Add a condition to include files",
                                       addConditionPromptButtonTitle: "Add a Condition",
                                       overviewExplanation: "Show files matching any of the following sets of rules:",
                                       editorExplanation: "Show files matching all of the following conditions:")
        
        let fileRules = RulesViewController<FileRule>(viewModel: viewModel)
        self .show(contentViewController: fileRules)
    }
    
    func showFolderRules() {
        print("Show folder rules")
        self.segmentedControl.selectedSegment = 1
        
        let viewModel = RulesViewModel(editRuleTitle: "Add Folder Rule",
                                       addConditionPrompt: "Add condtions to exclude a folder, even if it contains matching files",
                                       addConditionPromptButtonTitle: "Add a Condition",
                                       overviewExplanation: "Exclude folders matching any of the following sets of rules:",
                                       editorExplanation: "Exclude folders matching all of the following conditions:")
        
        let folderRules = RulesViewController<FolderRule>(viewModel: viewModel)
        self.show(contentViewController: folderRules)
    }
    
    func showSettings() {
        print("Show settings")
        self.segmentedControl.selectedSegment = 2
        
        let settings = SettingsViewController(nibName: "SettingsViewController", bundle: nil)!
        self.show(contentViewController: settings)
    }
    
    func show(contentViewController newViewController: NSViewController) {
        
        if let existing = contentViewController {
            existing.removeFromParentViewController()
            existing.view.removeFromSuperview()
        }
        
        addChildViewController(newViewController);
        contentView.addSubview(newViewController.view)
        newViewController.view.pinToSuperviewEdges()
        contentViewController = newViewController
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
            self.updatePathLabel()
            rebuild()
        }
    }
    
    @IBAction func addFileRuleButtonPressed(sender: NSButton){
        print("Add file type button pressed")
                
//        let editor = EditFileRuleViewController.create(existingRule: nil)
//        editor.delegate = self
//        
//        addChildViewController(editor)
//        view.addSubview(editor.view)
//        editor.view.pinToSuperviewEdges()
    }
    
    @IBAction private func addFolderRuleButtonPressed(sender: NSButton){
        print("Add folder rule button pressed")
    }
    
    @IBAction private func deleteFolderRuleButtonPressed(sender: NSButton){
        print("Delete folder rule button pressed")
    }
    
    @IBAction private func segmentedControlValueChanged(sender: NSSegmentedControl){
        
        switch segmentedControl.selectedSegment {
        case 0: showFileRules()
        case 1: showFolderRules()
        case 2: showSettings()
        default: fatalError("Unknown value")
        }
    }
    
    // MARK: - Update
    
    func updatePathLabel() {
        
        let text = Settings.path ?? "No path set"
        textField.stringValue = text
    }
    
    // MARK: - Rebuild
    
    func rebuild() {
        (NSApp.delegate as? AppDelegate)?.needsRebuild = true
    }
}
