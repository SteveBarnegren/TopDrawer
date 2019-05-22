//
//  NSTextField+Extensions.swift
//  MenuNav
//
//  Created by Steve Barnegren on 08/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit

public extension NSTextField {
    
    static func createWithLabelStyle() -> NSTextField {
        
        let textField = NSTextField(frame: .zero)
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        return textField
    }
    
    var stringValueOptional: String? {
        
        let text = stringValue
        return text == "" ? nil : text
    }
}
