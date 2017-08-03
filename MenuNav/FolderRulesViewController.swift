//
//  FolderRulesViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa
import SBAutoLayout

class FolderRulesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    // MARK: - Actions
    
    @IBAction private func addRuleButtonPressed(sender: NSButton){
        print("Add rule button pressed")
        
        guard let parentViewController = parent else {
            fatalError("Expected parent view controller")
        }
        
        let editRule = EditFolderRuleViewController.init(nibName: "EditFolderRuleViewController", bundle: nil)!
        
        // Reaching in to the parent here is terrible, will have to come up with a better solution
        parentViewController.addChildViewController(editRule)
        parentViewController.view.addSubview(editRule.view)
        editRule.view.pinToSuperviewEdges()
    }
    
}
