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
    private var rebuildManager: RebuildManager!

    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // IconImageView
        iconImageView.image = NSImage(named: NSImage.Name(rawValue: "AppIcon"))
        
        // Update UI
        updatePathLabel()
    }
    
    // MARK: - Pass in dependancies
    
    func configure(withRebuildManager rebuildManager: RebuildManager) {
        self.rebuildManager = rebuildManager
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
        
        let fileRules = RulesViewController<FileRule>(viewModel: viewModel, rebuildManager: rebuildManager)
        self .show(contentViewController: fileRules)
    }
    
    func showFolderRules() {
        print("Show folder rules")
        self.segmentedControl.selectedSegment = 1
        
        // swiftlint:disable line_length
        let viewModel = RulesViewModel(editRuleTitle: "Add Folder Rule",
                                       addConditionPrompt: "Add condtions to exclude a folder, even if it contains matching files",
                                       addConditionPromptButtonTitle: "Add a Condition",
                                       overviewExplanation: "Exclude folders matching any of the following sets of rules:",
                                       editorExplanation: "Exclude folders matching all of the following conditions:")
        // swiftlint:enable line_length
        
        let folderRules = RulesViewController<FolderRule>(viewModel: viewModel, rebuildManager: rebuildManager)
        self.show(contentViewController: folderRules)
    }
    
    func showSettings() {
        print("Show settings")
        self.segmentedControl.selectedSegment = 2
        
        let settings = SettingsViewController(rebuildManager: rebuildManager)
        self.show(contentViewController: settings)
    }
    
    func show(contentViewController newViewController: NSViewController) {
        
        if let existing = contentViewController {
            existing.removeFromParentViewController()
            existing.view.removeFromSuperview()
        }
        
        addChildViewController(newViewController)
        contentView.addSubview(newViewController.view)
        newViewController.view.pinToSuperviewEdges()
        contentViewController = newViewController
    }
    
    // MARK: - Actions
    
    @IBAction func chooseFolderButtonPressed(sender: NSButton) {
        print("Choose folder button pressed")
        
        let openDialogue = NSOpenPanel()
        
        openDialogue.title = "Choose a folder"
        openDialogue.showsResizeIndicator = true
        openDialogue.showsHiddenFiles = false
        openDialogue.canChooseDirectories = true
        openDialogue.canCreateDirectories = false
        openDialogue.allowedFileTypes = nil
        
        if openDialogue.runModal() == NSApplication.ModalResponse.OK {
            
            guard let result = openDialogue.url else {
                return
            }
            
            let path = result.path
            Settings.shared.path.value = path
            self.updatePathLabel()
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func segmentedControlValueChanged(sender: NSSegmentedControl) {
        
        switch segmentedControl.selectedSegment {
        case 0: showFileRules()
        case 1: showFolderRules()
        case 2: showSettings()
        default: fatalError("Unknown value")
        }
    }
    
    // MARK: - Update
    
    func updatePathLabel() {
        
        let path = Settings.shared.path.value
        
        textField.stringValue = path.isEmpty ? "No path set" : path
    }
    
}
