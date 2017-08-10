//
//  FolderRulesViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

class RulesViewController: NSViewController {
    
    // MARK: - Types
    
    enum State {
        case normal
        case newRule
        case editingRule(index: Int)
    }
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var collectionView: NSCollectionView!
    
    var state = State.normal
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        
        // Setup collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let flowLayout = NSCollectionViewFlowLayout()
        //flowLayout.itemSize = NSSize(width: 160, height: 140)
        flowLayout.sectionInset = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        collectionView.collectionViewLayout = flowLayout
    }

    // MARK: - Actions
    
    @IBAction private func addRuleButtonPressed(sender: NSButton){
        print("Add rule button pressed")
        
        addNewRule()
    }
    
    // MARK: - Navigation
    
    func addNewRule() {
        
        guard let parentViewController = parent else {
            fatalError("Expected parent view controller")
        }
        
        state = .newRule
        
        let editRule = EditFolderRuleViewController(existingRule: nil)
        editRule.delegate = self
        
        // Reaching in to the parent here is terrible, will have to come up with a better solution
        parentViewController.addChildViewController(editRule)
        parentViewController.view.addSubview(editRule.view)
        editRule.view.pinToSuperviewEdges()
    }
    
    func editRule(atIndex index: Int) {
        
        guard let parentViewController = parent else {
            fatalError("Expected parent view controller")
        }
        
        state = .editingRule(index: index)
        
        let rule = Settings.folderRules[index]
        let editRule = EditFolderRuleViewController(existingRule: rule)
        editRule.delegate = self
        
        // Reaching in to the parent here is terrible, will have to come up with a better solution
        parentViewController.addChildViewController(editRule)
        parentViewController.view.addSubview(editRule.view)
        editRule.view.pinToSuperviewEdges()
    }
}

private let conditionLabelHeight = CGFloat(20)
private let conditionLabelSpacing = CGFloat(2)

extension RulesViewController: NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return Settings.folderRules.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        
        let rule = Settings.folderRules[indexPath.item]
        let numConditions = CGFloat(rule.conditions.count)
        let height = (numConditions * conditionLabelHeight) + ((numConditions-1) * conditionLabelSpacing)
        return CGSize(width: collectionView.bounds.size.width,
                      height: height)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = collectionView.makeItem(withIdentifier: "FolderRuleCollectionViewItem", for: indexPath)
        
        guard let collectionViewItem = item as? FolderRuleCollectionViewItem else {
            fatalError("Unable to create collection view item")
        }
        
        let rule = Settings.folderRules[indexPath.item]
        collectionViewItem.configure(withRule: rule,
                                     conditionHeight: conditionLabelHeight,
                                     conditionSpacing: conditionLabelSpacing)
        collectionViewItem.delegate = self
        
        return collectionViewItem
    }
}

extension RulesViewController: FolderRuleCollectionViewItemDelegate {
    
    func folderRuleCollectionViewItemEditPressed(item: FolderRuleCollectionViewItem) {
        
        let indexPath = collectionView.indexPath(for: item)!
        print("Item selected at row: \(indexPath.item)")
        
        editRule(atIndex: indexPath.item)
    }
}

extension RulesViewController: EditFolderRuleViewControllerDelegate {
    
    func editFolderRuleViewControllerDidEditRule(_ rule: FolderRule) {
        
        switch state {
        case .newRule:
            Settings.add(folderRule: rule)
        case let .editingRule(index):
            Settings.update(folderRule: rule, atIndex: index)
        default:
            break
        }
        
        state = .normal
        collectionView.reloadData()
    }
}
