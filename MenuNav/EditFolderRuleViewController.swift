//
//  EditFolderRuleViewController.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Cocoa

class EditFolderRuleViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak fileprivate var matchTypePopup: NSPopUpButton!
    @IBOutlet weak fileprivate var scrollView: NSScrollView!
    
    // MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        // Match Type Popup
        matchTypePopup.removeAllItems()
        matchTypePopup.addItems(withTitles: ["all", "any"])
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let height = CGFloat(80);
        let frame = CGRect(x: 0, y: 0, width: scrollView.bounds.size.width, height: height)
        
        let conditionView = EditFolderConditionView(frame: frame)
        scrollView.addSubview(conditionView)
        conditionView.configure(withNode: folderConditionDecisionTree())
    }
    
}
