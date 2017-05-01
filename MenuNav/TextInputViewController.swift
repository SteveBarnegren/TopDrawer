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
    
    static func create(handler: @escaping (FileType) -> ()) -> NSViewController {
        
        let storyboard = NSStoryboard(name: "App", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "TextInputViewController") as! TextInputViewController
        viewController.handler = handler
        return viewController
    }
    
    // MARK: - Outlets
    @IBOutlet weak fileprivate var fileNameTextField: NSTextField!
    @IBOutlet weak fileprivate var extensionTextField: NSTextField!
    @IBOutlet weak fileprivate var readoutLabel: NSTextField!
    //@IBOutlet weak fileprivate var addButton: NSButton!
    //@IBOutlet weak fileprivate var notButton: NSButton!
    @IBOutlet weak private var addButtonStackView: NSStackView!
    @IBOutlet weak private var notButtonStackView: NSStackView!

    // MARK: - Properties
    fileprivate var handler: (FileType) -> () = {_ in}
    
    var canSubmit: Bool {
        return fileNameTextField.sanitisedText.length > 0 || extensionTextField.sanitisedText.length > 0
    }
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        // Text Field
        fileNameTextField.delegate = self
        extensionTextField.delegate = self
        
        // Update UI
        updateSubmitButtons()
        updateReadoutLabel()
    }
    
    // MARK: - Update UI
    
    fileprivate func updateSubmitButtons() {
        
        [addButtonStackView, notButtonStackView].forEach{
            $0.alphaValue = canSubmit ? 1 : 0
        }
        
        //submitButton.alphaValue = canSubmit ? 1 : 0
        //submitButton.isEnabled = canSubmit
    }
    
    fileprivate func updateReadoutLabel() {
        
        var fileName = fileNameTextField.sanitisedText
        var ext = extensionTextField.sanitisedText
        
        if fileName.length == 0 && ext.length == 0 {
            readoutLabel.alphaValue = 0
            return
        }
        
        
        if fileName.length == 0 {
            fileName = "*"
        }
        
        if ext.length == 0 {
            ext = "*"
        }
        
        readoutLabel.stringValue = fileName + "." + ext
        readoutLabel.alphaValue = 1
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonPressed(sender: NSButton){
        print("Add button pressed")
        submit(exclude: false)
    }
    
    @IBAction func notButtonPressed(sender: NSButton){
        print("Not button pressed")
        submit(exclude: true)
    }
    
    @IBAction func closeButtonPressed(sender: NSButton){
        view.removeFromSuperview()
        removeFromParentViewController()
    }
    
    // MARK: - Submit
    
    func submit(exclude: Bool) {
        
        let fileType = FileType(name: fileNameTextField.sanitisedText,
                                ext: extensionTextField.sanitisedText,
                                exclude: exclude)
        
        handler( fileType )
        
        view.removeFromSuperview()
        removeFromParentViewController()
    }

}

// MARK: - NSTextFieldDelegate
extension TextInputViewController: NSTextFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
    
        guard let textField = obj.object as? NSTextField else {
            fatalError("Couldn't obtain text field from delegate callback")
        }
        
        textField.stringValue = textField.sanitisedText
        
        updateSubmitButtons()
        updateReadoutLabel()
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
    
}


