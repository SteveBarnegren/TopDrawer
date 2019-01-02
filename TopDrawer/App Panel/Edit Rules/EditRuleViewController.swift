//
//  EditFolderRuleViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa

class EditRuleViewController<T: Rule>: NSViewController {
    
    // MARK: - Types
    
    enum State {
        case noConditions
        case invalidConditions
        case validConditions
    }
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var titleLabel: NSTextField!
    @IBOutlet weak fileprivate var scrollView: NSScrollView!
    @IBOutlet weak fileprivate var finishButton: NSButton!
    @IBOutlet weak fileprivate var explantionLabel: NSTextField!

    fileprivate var existingRule: T?
    fileprivate var conditionViews = [ConditionEditorView<T.Condition>]()
    
    var didEditRuleHandler: (T) -> Void = {_ in}
    
    private var state: State {
        
        if conditionViews.count == 0 {
            return .noConditions
        }
        
        if conditionViews.contains(where: { $0.hasValidCondition == false }) {
            return .invalidConditions
        }
        
        return .validConditions
    }
    
    private var promptView: ConditionPromptView!
    
    // MARK: - Init
    
    init(existingRule: T?, viewModel: RulesViewModel) {
        super.init(nibName: "EditRuleViewController", bundle: nil)
        
        self.existingRule = existingRule
        
        // Prompt view
        promptView = ConditionPromptView(prompt: viewModel.addConditionPrompt,
                                         buttonTitle: viewModel.addConditionPromptButtonTitle,
                                         handler: self.addConditionView)
        
        view.addSubview(promptView)
        promptView.pinToSuperviewEdges()
        
        // Title Label
        titleLabel.stringValue = viewModel.editRuleTitle
        
        // Explanation Label
        explantionLabel.stringValue = viewModel.editorExplanation
        
        // Update UI
        updateForCurrentState()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        // Set scrollview background color
        let scrollViewBackgroundColor = NSColor(calibratedWhite: 0.993, alpha: 1).cgColor
        
        scrollView.wantsLayer = true
        scrollView.layer?.backgroundColor = scrollViewBackgroundColor
        
        scrollView.documentView?.wantsLayer = true
        scrollView.documentView?.layer?.backgroundColor = scrollViewBackgroundColor
        
        // Create existing rule condition views
        if let rule = existingRule {
            
            rule.conditions.forEach {
                addConditionView(fromCondition: $0)
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        layoutConditionViews()
    }
    
    func layoutConditionViews() {
        
        // Layout the condition views
        let height = CGFloat(35)
        let contentHeight = max(scrollView.bounds.size.height, height * CGFloat(conditionViews.count))
        
        for (index, conditionView) in conditionViews.enumerated() {
            
            conditionView.frame = CGRect(x: 0,
                                         y: contentHeight - (CGFloat(index+1) * height),
                                         width: scrollView.bounds.size.width - 2,
                                         height: height)
        }
        
        scrollView.documentView?.frame = CGRect(x: 0,
                                                y: 0,
                                                width: scrollView.bounds.size.width - 2,
                                                height: contentHeight)
    }
    
    // MARK: - UI
    
    func updateForCurrentState() {
        
        switch state {
        case .noConditions:
            promptView.isHidden = false
            finishButton.isHidden = true
        case .invalidConditions:
            promptView.isHidden = true
            finishButton.isHidden = true
        case .validConditions:
            promptView.isHidden = true
            finishButton.isHidden = false
        }
    }
    
    // MARK: - Table
    
    func addConditionView() {
        addConditionView(fromCondition: nil)
    }
    
    func addConditionView(fromCondition: T.Condition?) {
                
        let tree = T.makeDecisionTree()
        if let condition = fromCondition {
            tree.matchTree(toElement: condition)
        }
        
        let conditionView = ConditionEditorView<T.Condition>(frame: .zero)
        scrollView.documentView?.addSubview(conditionView)
        conditionView.configure(withNode: tree)
        //conditionView.delegate = self
        conditionViews.append(conditionView)
        layoutConditionViews()
        
        conditionView.valueChangedHandler = conditionViewValueChanged
        conditionView.wantsDeletionHandler = conditionViewWantsDeletion
        
        view.needsLayout = true
        updateForCurrentState()
    }
    
    func removeConditionView(_ conditionView: ConditionEditorView<T.Condition>) {
        
        conditionViews.filter { $0 === conditionView }
            .forEach { $0.removeFromSuperview() }
        
        conditionViews = conditionViews.filter { $0 !== conditionView }
        
        view.needsLayout = true
        updateForCurrentState()
    }
    
    // MARK: - Actions
    
    @IBAction private func addButtonPressed(sender: NSButton) {
        print("add button pressed")
        addConditionView()
    }
    
    @IBAction private func finishButtonPressed(sender: NSButton) {
        print("Finish button pressed")
        
        let conditions = conditionViews.map { $0.makeCondition()! }
        let rule = T(conditions: conditions)
        // delegate?.editRuleViewControllerDidEditRule(rule)
        
        didEditRuleHandler(rule)
        
        dismiss()
    }
    
    @IBAction private func closeButtonPressed(sender: NSButton) {
        print("Close button pressed")
        dismiss()
    }
    
    // MARK: - Navigation
    
    func dismiss() {
        removeFromParent()
        view.removeFromSuperview()
    }
    
    // MARK: - ConditionViewHandlers
    
    func conditionViewValueChanged(_ conditionView: ConditionEditorView<T.Condition>) {
        print("VC: Condition value changed")
        updateForCurrentState()
    }
    
    func conditionViewWantsDeletion(_ conditionView: ConditionEditorView<T.Condition>) {
        print("VC: Condition wants deletion")
        removeConditionView(conditionView)
    }
    
}
