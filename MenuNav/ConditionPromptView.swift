//
//  EmptyTableActionView.swift
//  MenuNav
//
//  Created by Steve Barnegren on 08/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

class ConditionPromptView: NSView {
    
    // MARK: - Properties
    
    private let handler: () -> ()
    
    private lazy var stackView: NSStackView = {
        let stackView = NSStackView(views: [self.promptLabel, self.actionButton])
        stackView.orientation = .vertical
        return stackView
    }()
    
    private lazy var promptLabel: NSTextField = {
        let label = NSTextField.createWithLabelStyle()
        return label
    }()
    
    private lazy var actionButton: NSButton = {
        let button = NSButton(title: "Action", image: NSImage(), target: self, action: #selector(actionButtonPressed))
        return button
    }()
    
    
    // MARK: - Init
    
    init(prompt: String, buttonTitle: String, handler: @escaping () -> ()) {
        
        self.handler = handler
        
        super.init(frame: .zero)
        
        // Stack view
        addSubview(stackView)
        stackView.pinToSuperviewCenter()
        
        // Message label
        promptLabel.stringValue = prompt
        
        // Action Button
        actionButton.title = buttonTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonPressed() {
        Swift.print("Action button pressed")
        handler()
    }
}
