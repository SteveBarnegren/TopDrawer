//
//  RichTextAttributes.swift
//  MenuNav
//
//  Created by Steve Barnegren on 30/09/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit
import AttributedStringBuilder

struct RichTextAttributes {
    
    let font: NSFont
    let color: NSColor
    let boldFont: NSFont
    let boldColor: NSColor
    
    var regularAttributes: [AttributedStringBuilder.Attribute] {
        return [.font(font), .textColor(color)]
    }
    
    var boldAttributes: [AttributedStringBuilder.Attribute] {
        return [.font(boldFont), .textColor(boldColor)]
    }
    
    var italicAttributes: [AttributedStringBuilder.Attribute] {
        return [.font(font), .textColor(color), .skew(0.1)]
    }
}
