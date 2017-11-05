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
        let button = NSButton(title: "",
                              image: NSImage(named: NSImage.Name(rawValue: "Edit"))!,
                              target: self,
                              action: #selector(selectPathButtonPressed(_:)))
        return button
    }()
    
    private lazy var stackView: NSStackView = {
        let stackView = NSStackView(views: [self.textField, self.button])
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        stackView.pinToSuperviewEdges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
