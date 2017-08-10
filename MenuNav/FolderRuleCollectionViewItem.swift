//
//  FolderRuleCollectionViewItem.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

protocol FolderRuleCollectionViewItemDelegate: class {
    func folderRuleCollectionViewItemEditPressed(item: FolderRuleCollectionViewItem)
}

class FolderRuleCollectionViewItem: NSCollectionViewItem {
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var conditionsStackView: NSStackView!
    weak var delegate: FolderRuleCollectionViewItemDelegate?

    let conditionFormatter = FolderConditionFormatter()
    
    // MARK: - Configure
    
    func configure(withRule rule: FolderRule,
                   conditionHeight: CGFloat,
                   conditionSpacing: CGFloat) {
        
        conditionsStackView.subviews.forEach{
            $0.removeFromSuperview()
        }
        //conditionsStackView.spacing = conditionSpacing
        
        rule.conditions.forEach{

            let label = NSTextField.createWithLabelStyle()
            label.stringValue = conditionFormatter.string(fromCondition: $0)
            conditionsStackView.addArrangedSubview(label)
            //label.pinHeight(conditionHeight)
        }
        
        view.needsLayout = true
    }
    
    
    // MARK: - NSCollectionViewItem
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.orange.cgColor
    }
    
    // MARK: - Actions
    
    @IBAction private func editButtonPressed(sender: NSButton){
        print("Edit button pressed")
        delegate?.folderRuleCollectionViewItemEditPressed(item: self)
    }
    
}
