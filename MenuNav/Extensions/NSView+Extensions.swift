//
//  NSView+Extensions.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit

extension NSView {
    
    var backgroundColor: NSColor? {
        set {
            if let color = newValue {
                wantsLayer = true
                layer?.backgroundColor = color.cgColor
            }
        }
        get {
            if let color = layer?.backgroundColor {
                return NSColor(cgColor: color)
            } else {
                return nil
            }
        }
    }
}
