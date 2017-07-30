//
//  TextInputViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/05/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

protocol EditRuleViewControllerDelegate: class {
    func editRuleViewController(_ editRuleViewController: EditRuleViewController, didUpdateRule rule: FileRule)
}

class EditRuleViewController: NSViewController {

    // MARK: - Internal
    
    static func create(existingRule: FileRule?) -> EditRuleViewController {
        
        let storyboard = NSStoryboard(name: "App", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "EditRuleViewController") as! EditRuleViewController
        
        if let rule = existingRule {
            viewController.ruleConstructor = FileRuleConstructor(rule: rule)
        }
        else{
            viewController.ruleConstructor = FileRuleConstructor()
        }
        
        return viewController
    }
    
    // MARK: - Outlets
    @IBOutlet weak fileprivate var filterSegmentedControl: NSSegmentedControl!
    @IBOutlet weak fileprivate var targetSegmentedControl: NSSegmentedControl!
    @IBOutlet weak fileprivate var nameTextField: NSTextField!
    @IBOutlet weak fileprivate var extensionTextField: NSTextField!
    @IBOutlet weak fileprivate var readoutLabel: NSTextField!
    @IBOutlet weak fileprivate var submitButton: NSButton!

    // MARK: - Properties
    fileprivate var ruleConstructor: FileRuleConstructor!

    weak var delegate: EditRuleViewControllerDelegate?
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        
        // Text Fields
        nameTextField.delegate = self
        extensionTextField.delegate = self
        
        // Update UI
        updateFilterSegmentedControl()
        updateTargetSegmentedControl()
        updateNameTextField()
        updateExtensionTextField()
        updateSubmitButton()
        updateReadoutLabel()
    }
    
    // MARK: - Update UI from rule
    
    private func updateFilterSegmentedControl() {
        
        switch ruleConstructor.filter{
        case .include:
            filterSegmentedControl.setSelected(true, forSegment: 0)
            filterSegmentedControl.setSelected(false, forSegment: 1)
        case .exclude:
            filterSegmentedControl.setSelected(false, forSegment: 0)
            filterSegmentedControl.setSelected(true, forSegment: 1)
        }
    }
    
    private func updateTargetSegmentedControl() {
        
        switch ruleConstructor.targetType {
        case .files:
            targetSegmentedControl.setSelected(true, forSegment: 0)
            targetSegmentedControl.setSelected(false, forSegment: 1)
        case .folders:
            targetSegmentedControl.setSelected(false, forSegment: 0)
            targetSegmentedControl.setSelected(true, forSegment: 1)
        }
    }
    
    private func updateNameTextField() {
        
        switch ruleConstructor.targetType {
        case .files:
            nameTextField.placeholderString = "File Name"
        case .folders:
            nameTextField.placeholderString = "Folder Name"
        }
        
        nameTextField.stringValue = ruleConstructor.itemName ?? ""
    }
    
    private func updateExtensionTextField() {
        
        switch ruleConstructor.targetType {
        case .files:
            extensionTextField.placeholderString = "Extension"
            extensionTextField.stringValue = ruleConstructor.itemExtension ?? ""
            extensionTextField.isHidden = false
        case .folders:
            extensionTextField.placeholderString = "Folder Name"
            extensionTextField.stringValue = ruleConstructor.itemExtension ?? ""
            extensionTextField.isHidden = true
        }
    }
    
    fileprivate func updateReadoutLabel() {
        
        let formatter = FileRuleFormatter()
        
        if  let rule = ruleConstructor.rule,
            let description = formatter.string(fromRule: rule){
            
            readoutLabel.stringValue = description
        }
        else{
            readoutLabel.stringValue = ""
        }
        
    }
    
    fileprivate func updateSubmitButton() {
        submitButton.isHidden = !ruleConstructor.canMakeRule
    }
    
    // MARK: - Update Rule from UI
    
    func configureRuleFromUI() {
        
        // Filter
        ruleConstructor.filter = FileRule.Filter(rawValue: filterSegmentedControl.selectedSegment)!
        
        // Target
        ruleConstructor.itemName = nameTextField.stringValueNilIfEmpty
        ruleConstructor.itemExtension = extensionTextField.stringValueNilIfEmpty
        
        switch targetSegmentedControl.selectedSegment {
        case 0:
            ruleConstructor.targetType = .files
        case 1:
            ruleConstructor.targetType = .folders
        default:
            fatalError()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonPressed(sender: NSButton){
        view.removeFromSuperview()
        removeFromParentViewController()
    }
    
    @IBAction private func filterSegmentedControlValueChanged(sender: NSSegmentedControl){
        print("Fiter segmented control value changed")
        configureRuleFromUI()
        updateReadoutLabel()
        updateSubmitButton()
    }
    
    @IBAction private func targetSegmentedControlValueChanged(sender: NSSegmentedControl){
        print("Target segmented control value changed")
        configureRuleFromUI()
        updateReadoutLabel()
        updateSubmitButton()
    }
    
    @IBAction private func submitButtonPressed(sender: NSButton){
        print("Submit button pressed")
        submit()
    }

    // MARK: - Submit
    
    func submit() {
        
        guard let rule = ruleConstructor.rule else {
            print("Warning - Attempted to create invalid rule")
            return
        }
        
        delegate?.editRuleViewController(self, didUpdateRule: rule)
    }
}

// MARK: - NSTextFieldDelegate
extension EditRuleViewController: NSTextFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
    
        guard let textField = obj.object as? NSTextField else {
            fatalError("Couldn't obtain text field from delegate callback")
        }
        
        textField.stringValue = textField.sanitisedText
        configureRuleFromUI()
        updateReadoutLabel()
        updateSubmitButton()
    }
}

extension NSTextField {
    
    var sanitisedText: String {
        
        var text = stringValue
        text = text.trimmed()
        
        if text.contains(" ") {
            text = text.components(separatedBy: " ").first!
        }
        
        return text
    }
    
    var stringValueNilIfEmpty: String? {
        
        let text = stringValue
        return text == "" ? nil : text
    }
}


