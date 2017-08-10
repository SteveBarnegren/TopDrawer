//
//  EditFolderConditionView.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

protocol EditFolderConditionViewDelegate: class {
    func editFolderConditionViewWantsDeletion(conditionView: EditFolderConditionView)
    func editFolderConditionViewValueChanged(conditionView: EditFolderConditionView)
}

class EditFolderConditionView: NSView {
    
    // MARK: - Preperties
    
    weak var delegate: EditFolderConditionViewDelegate?
    private var views = [NSView]()
    private var node: DecisionNode<FolderRule.Condition>!
    fileprivate var viewsAndNodes = Dictionary<NSView, DecisionNode<FolderRule.Condition>>()
    
    private let stackView: NSStackView = {
        let sv = NSStackView(frame: .zero)
        sv.alignment = .left
        sv.orientation = .horizontal
        return sv
    }()
    
    private lazy var deleteButton: NSButton = {
        let button = NSButton(title: "D", image: NSImage(), target: self, action: #selector(deleteButtonPressed))
        return button
    }()
    
    private lazy var validityIndicator: NSTextField = {
        let textField = NSTextField.createWithLabelStyle()
        return textField
    }()
    
    var hasValidCondition: Bool {
        return makeCondition() != nil
    }
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        addSubview(stackView)
        stackView.pinToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    private func reconfigure() {
        configure(withNode: node)
    }
    
    func configure(withNode node: DecisionNode<FolderRule.Condition>) {
        
        self.node = node
        
        // Remove existing
        views.forEach{
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        views.removeAll()
        viewsAndNodes.removeAll()
        
        // Add new views
        func addViewToStackView(_ aView: NSView, fromNode node: DecisionNode<FolderRule.Condition>) {
            stackView.addArrangedSubview(aView)
            views.append(aView)
            viewsAndNodes[aView] = node
        }
        
        // Recusively add controls
        func addControl(forNode node: DecisionNode<FolderRule.Condition>) {
            
            switch node.nodeType {
            case let .list(_, itemNodes):
                
                let popupButton = makePopupButton()
                itemNodes.forEach{
                    popupButton.addItem(withTitle: $0.name)
                }
                popupButton.selectItem(at: node.selectedIndex)
                addViewToStackView(popupButton, fromNode: node)
                addControl(forNode: itemNodes[node.selectedIndex])
            
            case let .textValue(_, placeholder, _):
                
                let textField = self.makeTextField()
                textField.placeholderString = placeholder
                textField.stringValue = node.textValue ?? ""
                addViewToStackView(textField, fromNode: node)
            }
        }
        
        addControl(forNode: node)
        
        // Ad the validitiy indicator
        if validityIndicator.superview != nil {
            validityIndicator.removeFromSuperview()
        }
        stackView.addArrangedSubview(validityIndicator)
        
        // Add the delete button
        if deleteButton.superview != nil {
            deleteButton.removeFromSuperview()
        }
        stackView.addArrangedSubview(deleteButton)
    }
    
    // MARK: - Make Views
    
    private func makePopupButton() -> NSPopUpButton {
        
        let button = NSPopUpButton(frame: .zero)
        button.removeAllItems()
        button.target = self
        button.action = #selector(popupButtonValueChanged(button:))
        return button
    }
    
    private func makeTextField() -> NSTextField {
        
        let textField = NSTextField(frame: .zero)
        textField.delegate = self
        return textField
    }
    
    // MARK: - Actions
    
    @objc private func popupButtonValueChanged(button: NSPopUpButton){
        
        guard let item = button.selectedItem else {
            Swift.print("Unable to find selected item")
            return
        }
        
        let index = button.index(of: item)
        Swift.print("index = \(index)")
        
        guard let node = viewsAndNodes[button] else {
            Swift.print("Unable to find node")
            return
        }
        node.selectedIndex = index
        reconfigure()
        updateValidityIndicator()
        
        delegate?.editFolderConditionViewValueChanged(conditionView: self)
    }
    
    @objc private func deleteButtonPressed() {
        Swift.print("Delete button pressed")
        
        delegate?.editFolderConditionViewWantsDeletion(conditionView: self)
    }
    
    // MARK: - Update UI
    
    fileprivate func updateValidityIndicator() {
        
        if hasValidCondition {
            validityIndicator.stringValue = "Y"
        }
        else{
            validityIndicator.stringValue = "N"
        }
    }
    
    // MARK: - Condition
    
    func makeCondition() -> FolderRule.Condition? {
        return node.make()
    }
    
}

// MARK: - NSTextFieldDelegate
extension EditFolderConditionView: NSTextFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
        
        guard let textField = obj.object as? NSTextField else {
            fatalError("Couldn't obtain text field from delegate callback")
        }
        
        let node = viewsAndNodes[textField]
        node?.textValue = textField.stringValueOptional
        updateValidityIndicator()
        
        delegate?.editFolderConditionViewValueChanged(conditionView: self)
    }
}
