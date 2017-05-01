//
//  TextInputViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/05/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

class TextInputViewController: NSViewController {

    // MARK: - Internal
    
    static func create(title: String, button: String, handler: @escaping (String) -> ()) -> NSViewController {
        
        let storyboard = NSStoryboard(name: "App", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "TextInputViewController") as! TextInputViewController
        viewController.titleText = title
        viewController.buttonText = button
        viewController.handler = handler
        return viewController
    }
    
    var trimInput = true
    var disableWhiteSpace = true
    
    // MARK: - Outlets
    @IBOutlet weak fileprivate var titleLabel: NSTextField!
    @IBOutlet weak fileprivate var textField: NSTextField!
    @IBOutlet weak fileprivate var button: NSButton!
    
    // MARK: - Properties
    fileprivate var titleText: String!
    fileprivate var buttonText: String!
    fileprivate var handler: (String) -> () = {_ in}
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        // Title Label
        titleLabel.stringValue = titleText
        
        // Text Field
        textField.delegate = self
        
        // Button
        button.title = buttonText
        
        // Update UI
        updateButton()
    }
    
    // MARK: - Update UI
    
    fileprivate func updateButton() {
        
        let isVisible = (getFileTypeText().length > 0)
        
        button.alphaValue = isVisible ? 1 : 0
        button.isEnabled = isVisible
    }
    
    // MARK: - Get Text
    
    fileprivate func getFileTypeText() -> String {
        
        var text = textField.stringValue
        
        if trimInput {
            text = text.trimmed()
        }
        
        if disableWhiteSpace && text.contains(" ") {
            text = text.components(separatedBy: " ").first!
        }
        
        return text
    }
    
    // MARK: - Actions
    
    @IBAction func submitButtonPressed(sender: NSButton){
        print("Submit button pressed")
        handler(getFileTypeText())
        view.removeFromSuperview()
        removeFromParentViewController()
    }
    
    @IBAction func closeButtonPressed(sender: NSButton){
        view.removeFromSuperview()
        removeFromParentViewController()
    }

}

// MARK: - NSTextFieldDelegate
extension TextInputViewController : NSTextFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
        
        textField.stringValue = getFileTypeText()
        print("Text field text changed to: \(textField.stringValue)")
        updateButton()
    }
}
