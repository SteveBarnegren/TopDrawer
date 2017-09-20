//
//  PathConditionInputView.swift
//  MenuNav
//
//  Created by Steve Barnegren on 30/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit
import SBAutoLayout

class PathConditionInputView: NSView {
    
    // MARK: - Public
    
    var placeholder: String? {
        get { return textField.placeholderString }
        set { textField.placeholderString = newValue }
    }
    
    var path: String? {
        get { return textField.stringValue == "" ? nil : textField.stringValue }
        set { textField.stringValue = newValue ?? "" }
    }
    
    var valueChangedHandler: () -> Void = {}
    
    // MARK: - Properties

    private lazy var textField: NSTextField = {
        
        let textField = NSTextField(frame: .zero)
        textField.setContentHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.defaultLow, for: .horizontal)
        textField.delegate = self
        return textField
    }()
    
    private lazy var button: NSButton = {
        let button = NSButton(title: "P",
                              image: NSImage(),
                              target: self,
                              action: #selector(selectPathButtonPressed(_:)))
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.orange.cgColor

        addSubview(textField)
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView
    
    override func layout() {
        super.layout()
        
        textField.sizeToFit()
        button.sizeToFit()
        let height = textField.frame.size.height
        
        // Label
        textField.frame = CGRect(x: 0,
                             y: bounds.size.height - height,
                             width: bounds.size.width - button.frame.size.width,
                             height: height)
        
        // Button
        button.frame = CGRect(x: textField.bounds.size.width,
                              y: bounds.size.height - height,
                              width: button.frame.size.width,
                              height: height)
    }
    
    // MARK: - Actions
    
    @objc private func selectPathButtonPressed(_ button: NSButton) {
        Swift.print("Select path button pressed")
        
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
            
            path = result.path
            textFieldValueChanged()
        }
    }
    
    func textFieldValueChanged() {
        Swift.print("Text field value changed")
        valueChangedHandler()
    }
    
}

extension PathConditionInputView: NSTextFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
        self.textFieldValueChanged()
    }
}
