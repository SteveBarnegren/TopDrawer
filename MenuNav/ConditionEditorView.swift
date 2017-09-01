//
//  EditFolderConditionView.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

//protocol ConditionEditorViewDelegate: class {
//    associatedtype T: DecisionTreeElement
//    func conditionEditorViewWantsDeletion(conditionView: ConditionEditorView<T>)
//    func conditionEditorViewValueChanged(conditionView: ConditionEditorView<T>)
//}

class ConditionEditorView<T: DecisionTreeElement>: NSView {
    
    // MARK: - Preperties
    
    private let nonGenericType = ConditionEditorViewNonGenericType()
    private var views = [NSView]()
    private var node: DecisionNode<T>!
    fileprivate var viewsAndNodes = Dictionary<NSView, DecisionNode<T>>()
    
    var wantsDeletionHandler: (ConditionEditorView<T>) -> () = {_ in}
    var valueChangedHandler: (ConditionEditorView<T>) -> () = {_ in}
    
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
        
        nonGenericType.delegate = self
        
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
    
    func configure(withNode node: DecisionNode<T>) {
        
        self.node = node
        
        // Remove existing
        views.forEach{
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        views.removeAll()
        viewsAndNodes.removeAll()
        
        // Add new views
        func addViewToStackView(_ aView: NSView, fromNode node: DecisionNode<T>) {
            stackView.addArrangedSubview(aView)
            views.append(aView)
            viewsAndNodes[aView] = node
        }
        
        // Recusively add controls
        func addControl(forNode node: DecisionNode<T>) {
            
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
                
            case let .pathValue(_, placeholder, _):
                
                let pathView = self.makePathInputView()
                pathView.placeholder = placeholder
                addViewToStackView(pathView, fromNode: node)
            }
        }
        
        addControl(forNode: node)
        
        // Add the validitiy indicator
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
        textField.delegate = nonGenericType
        return textField
    }
    
    private func makePathInputView() -> PathConditionInputView {
        
        let input = PathConditionInputView(frame: .zero)

        input.valueChangedHandler = { [weak self, input] in
            self?.nodeViewChanged(input)
        }
        
        return input
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
        
        valueChangedHandler(self)
        
        //delegate?.conditionEditorViewValueChanged(conditionView: self)
    }
    
    @objc private func deleteButtonPressed() {
        Swift.print("Delete button pressed")
        
        wantsDeletionHandler(self)
        
        //delegate?.conditionEditorViewWantsDeletion(conditionView: self)
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
    
    func makeCondition() -> T? {
        return node.make()
    }
    
    // MARK: - Node updates
    
    func nodeViewChanged(_ nodeView: NSView) {
        
        let node = viewsAndNodes[nodeView]
        
        if let textField = nodeView as? NSTextField {
            node?.textValue = textField.stringValueOptional
        }
        else if let pathInputView = nodeView as? PathConditionInputView {
            node?.textValue = pathInputView.path
        }
        else{
            fatalError("Unknown node view type")
        }
        
        updateValidityIndicator()
        
        valueChangedHandler(self)
    }
    
}

extension ConditionEditorView: ConditionEditorViewNonGenericTypeDelegate {
    
    func controlTextDidChange(notification: Notification) {
        
        guard let textField = notification.object as? NSTextField else {
            fatalError("Couldn't obtain text field from delegate callback")
        }
        
        nodeViewChanged(textField)
    }
}

// MARK: - ConditionEditorViewObjCBridge

protocol ConditionEditorViewNonGenericTypeDelegate: class {
    func controlTextDidChange(notification: Notification)
}

class ConditionEditorViewNonGenericType: NSObject, NSTextFieldDelegate {
    
    weak var delegate: ConditionEditorViewNonGenericTypeDelegate?
    
    override func controlTextDidChange(_ obj: Notification) {
        delegate?.controlTextDidChange(notification: obj)
    }
}
