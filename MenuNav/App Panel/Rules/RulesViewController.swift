//
//  RulesViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

class RulesViewController<T: Rule>: NSViewController {
    
    // MARK: - Types
    
    enum State {
        case normal
        case newRule
        case editingRule(index: Int)
    }
    
    // MARK: - Properties
    
    @IBOutlet weak fileprivate var collectionView: NSCollectionView!
    @IBOutlet weak fileprivate var explanationLabel: NSTextField!
    
    let dataSource = RulesCollectionDataSource()
    var state = State.normal
    let ruleLoader = RuleLoader<T>(keyValueStore: UserPreferences())
    let viewModel: RulesViewModel
    let rebuildManager: RebuildManager
    
    // MARK: - Init
    
    init(viewModel: RulesViewModel, rebuildManager: RebuildManager) {
        self.viewModel = viewModel
        self.rebuildManager = rebuildManager
        super.init(nibName: NSNib.Name(rawValue: "RulesViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        
        //collectionView.register(RuleCollectionViewItem<T>.self, forItemWithIdentifier: "RuleCollectionViewItem")
        
        // Setup datasource
        dataSource.provider = self
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        // Collection view layout
        let flowLayout = NSCollectionViewFlowLayout()
        //flowLayout.itemSize = NSSize(width: 160, height: 140)
        flowLayout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        collectionView.collectionViewLayout = flowLayout
        
        // Explanation Label
        explanationLabel.textColor = Colors.lightTextColor
        explanationLabel.stringValue = viewModel.overviewExplanation
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        collectionView.collectionViewLayout?.invalidateLayout()
    }

    // MARK: - Actions
    
    @IBAction private func addRuleButtonPressed(sender: NSButton) {
        print("Add rule button pressed")
        
        addNewRule()
    }
    
    // MARK: - Navigation
    
    func addNewRule() {
        
        guard let parentViewController = parent else {
            fatalError("Expected parent view controller")
        }
        
        state = .newRule
        
        let editRule = EditRuleViewController<T>(existingRule: nil, viewModel: viewModel)
        editRule.didEditRuleHandler = didEditRuleHandler
        
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
        
        let rule = ruleLoader.rules[index]
        let editRule = EditRuleViewController(existingRule: rule, viewModel: viewModel)
        editRule.didEditRuleHandler = didEditRuleHandler
        
        // Reaching in to the parent here is terrible, will have to come up with a better solution
        parentViewController.addChildViewController(editRule)
        parentViewController.view.addSubview(editRule.view)
        editRule.view.pinToSuperviewEdges()
    }
    
    // MARK: - Edit Rule Delegation
    
    func didEditRuleHandler(rule: T) {
        
        let ruleLoader = RuleLoader<T>(keyValueStore: UserPreferences())
        
        switch state {
        case .newRule:
            ruleLoader.add(rule: rule)
        case let .editingRule(index):
            ruleLoader.update(rule: rule, atIndex: index)
        default:
            break
        }
        
        state = .normal
        collectionView.reloadData()
        
        rebuildManager.needsRebuild = true
    }
}

private let conditionLabelHeight = CGFloat(20)
private let conditionLabelSpacing = CGFloat(2)

extension RulesViewController: RulesCollectionDataSourceProvider {
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return ruleLoader.numberOfRules
    }
    
    func sizeForItem(atIndexPath indexPath: IndexPath) -> CGSize {
        
        let verticalMargins = CGFloat(3)
        
        print("Collection view width: \(self.collectionView.bounds.size.width)")
        
        let rule = ruleLoader.rules[indexPath.item]
        let numConditions = CGFloat(rule.conditions.count)
        let height = (numConditions * conditionLabelHeight) + ((numConditions-1) * conditionLabelSpacing)
        return CGSize(width: collectionView.bounds.size.width,
                      height: height + (verticalMargins*2))
    }
    
    func itemForObject(atIndexPath indexPath: IndexPath) -> NSCollectionViewItem {
        
        let identifier = NSUserInterfaceItemIdentifier(rawValue: "RuleCollectionViewItem")
        let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath)
        
        guard let collectionViewItem = item as? RuleCollectionViewItem else {
            fatalError("Unable to create collection view item")
        }
        
        let rule = ruleLoader.rules[indexPath.item]
        collectionViewItem.configure(withRule: rule,
                                     conditionHeight: conditionLabelHeight,
                                     conditionSpacing: conditionLabelSpacing)
        collectionViewItem.delegate = self
        
        return collectionViewItem
    }
}

extension RulesViewController: RuleCollectionViewItemDelegate {
    
    func ruleCollectionViewItemEditPressed(item: RuleCollectionViewItem) {
        
        let indexPath = collectionView.indexPath(for: item)!
        print("Item selected at row: \(indexPath.item)")
        
        editRule(atIndex: indexPath.item)
    }
    
    func ruleCollectionViewItemDeletePressed(item: RuleCollectionViewItem) {
        
        let indexPath = collectionView.indexPath(for: item)!
        print("Item selected at row: \(indexPath.item)")
        
        ruleLoader.deleteRule(atIndex: indexPath.item)
        collectionView.reloadData()
        
        rebuildManager.needsRebuild = true
    }
}

/*
extension RulesViewController: EditRuleViewControllerDelegate {
    
    func editRuleViewControllerDidEditRule(_ rule: FolderRule) {
        
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
 */

// MARK: - RulesViewControllerDataSource

// Generic types cannot implement ObjC protocols,
// so RulesCollectionDataSource is a non-generic
// bridge to implement collection view datasource

protocol RulesCollectionDataSourceProvider: class {
    
    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    func sizeForItem(atIndexPath indexPath: IndexPath) -> CGSize
    func itemForObject(atIndexPath indexPath: IndexPath) -> NSCollectionViewItem
}

class RulesCollectionDataSource: NSObject,
                                 NSCollectionViewDataSource,
                                 NSCollectionViewDelegate,
                                 NSCollectionViewDelegateFlowLayout {
    
    weak var provider: RulesCollectionDataSourceProvider!
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return provider.numberOfSections()
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return provider.numberOfItems(inSection: section)
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
   
        return provider.sizeForItem(atIndexPath: indexPath)
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        return provider.itemForObject(atIndexPath: indexPath)
    }
}
