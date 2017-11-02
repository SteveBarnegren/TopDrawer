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

struct ConditionFormatterAttributes {
    
    let regularFont: NSFont
    let regularColor: NSColor
    let typeEmphasisFont: NSFont
    let typeEmphasisColor: NSColor
    let nameEmphasisFont: NSFont
    let nameEmphasisColor: NSColor
    
    static let standard: ConditionFormatterAttributes = {
        let font = NSFont.systemFont(ofSize: 10)
        let color = NSColor.black
        return ConditionFormatterAttributes(regularFont: font,
                                            regularColor: color,
                                            typeEmphasisFont: font,
                                            typeEmphasisColor: color,
                                            nameEmphasisFont: font,
                                            nameEmphasisColor: color)
    }()
    
    var regularAttributes: [AttributedStringBuilder.Attribute] {
        return [.font(regularFont), .textColor(regularColor)]
    }
    
    var typeEmphasisAttributes: [AttributedStringBuilder.Attribute] {
        return [.font(typeEmphasisFont), .textColor(typeEmphasisColor)]
    }
    
    var nameEmphasisAttributes: [AttributedStringBuilder.Attribute] {
        return [.font(nameEmphasisFont), .textColor(nameEmphasisColor)]
    }
}
