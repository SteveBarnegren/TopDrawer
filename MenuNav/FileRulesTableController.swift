//
//  FileRulesDatasource.swift
//  MenuNav
//
//  Created by Steve Barnegren on 01/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit

class FileRulesTableController: NSObject {}

extension FileRulesTableController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Settings.fileRules.count
    }
}

extension FileRulesTableController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = "FileExtensionCell"
        
        guard let cell = tableView.make(withIdentifier: identifier, owner: nil) as? NSTableCellView else {
            fatalError("Unable to create table cell")
        }
        
        let rule = Settings.fileRules[row]
        
        let formatter = FileRuleFormatter()
        cell.textField?.stringValue = formatter.string(fromRule: rule) ?? "Unable to create description"
        //cell.imageView?.image = NSWorkspace.shared().icon(forFileType: fileType.ext ?? "" )
        
        return cell
    }
}
