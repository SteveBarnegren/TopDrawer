//
//  TextInputViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/05/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

protocol EditFileRuleViewControllerDelegate: class {
    func editFileRuleViewController(_ editFileRuleViewController: EditFileRuleViewController, didUpdateRule rule: FileRule)
}

class EditFileRuleViewController: NSViewController {

    // MARK: - Internal
    
    static func create(existingRule: FileRule?) -> EditFileRuleViewController {
        
        let storyboard = NSStoryboard(name: "App", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "EditFileRuleViewController") as! EditFileRuleViewController
        
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
    @IBOutlet weak fileprivate var nameTextField: NSTextField!
    @IBOutlet weak fileprivate var extensionTextField: NSTextField!
    @IBOutlet weak fileprivate var readoutLabel: NSTextField!
    @IBOutlet weak fileprivate var submitButton: NSButton!

    // MARK: - Properties
    fileprivate var ruleConstructor: FileRuleConstructor!

    weak var delegate: EditFileRuleViewControllerDelegate?
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        
        // Name text field
        nameTextField.placeholderString = "Name"
        nameTextField.delegate = self
        
        // Extension text field
        extensionTextField.placeholderString = "Extension"
        extensionTextField.delegate = self
        
        // Update UI
        updateFilterSegmentedControl()
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
    
    private func updateNameTextField() {
        nameTextField.stringValue = ruleConstructor.itemName ?? ""
    }
    
    private func updateExtensionTextField() {
        extensionTextField.stringValue = ruleConstructor.itemExtension ?? ""
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
        
        delegate?.editFileRuleViewController(self, didUpdateRule: rule)
    }
}

// MARK: - NSTextFieldDelegate
extension EditFileRuleViewController: NSTextFieldDelegate {
    
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


