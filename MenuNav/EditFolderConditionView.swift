//
//  EditFolderConditionView.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

class EditFolderConditionView: NSView {
    
    // MARK: - Preperties
    
    var views = [NSView]()
    var node: DecisionNode<FolderRule.Condition>!
    var viewsAndNodes = Dictionary<NSView, DecisionNode<FolderRule.Condition>>()
    
    let stackView: NSStackView = {
        let sv = NSStackView(frame: .zero)
        sv.alignment = .left
        sv.orientation = .horizontal
        return sv
    }()
    
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
    
    func reconfigure() {
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
        
        // Add new controls
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
                
            case let .textValues(_, placeholders, _):
                
                for placeholder in placeholders{
                    let textField = self.makeTextField()
                    textField.placeholderString = placeholder
                    textField.stringValue = node.textValue ?? ""
                    addViewToStackView(textField, fromNode: node)
                }
            }
        }
        
        addControl(forNode: node)
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
        
    }
    
    
    
}


