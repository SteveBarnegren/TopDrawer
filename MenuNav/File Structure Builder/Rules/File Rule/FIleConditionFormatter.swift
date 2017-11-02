//
//  FIleConditionFormatter.swift
//  MenuNav
//
//  Created by Steve Barnegren on 03/10/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AttributedStringBuilder

class FileConditionFormatter {
    
    func string(fromCondition condition: FileRule.Condition) -> String {
        
        let font = NSFont.systemFont(ofSize: 10)
        let color = NSColor.black
        let attributes = ConditionFormatterAttributes(regularFont: font,
                                                      regularColor: color,
                                                      typeEmphasisFont: font,
                                                      typeEmphasisColor: color,
                                                      nameEmphasisFont: font,
                                                      nameEmphasisColor: color)
        
        return attributedString(fromCondition: condition, withAttributes: attributes).string
    }
    
    func attributedString(fromCondition condition: FileRule.Condition,
                          withAttributes attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        switch condition {
        case let .name(stringMatcher):
            
            return AttributedStringBuilder()
                .text("Name ", attributes: attributes.typeEmphasisAttributes)
                .attributedText( makeAttributedString(fromStringMatcher: stringMatcher, attributes: attributes) )
                .attributedString
            
        case let .ext(stringMatcher):
            
            return AttributedStringBuilder()
                .text("Extension ", attributes: attributes.typeEmphasisAttributes)
                .attributedText( makeAttributedString(fromStringMatcher: stringMatcher, attributes: attributes) )
                .attributedString
            
        case let .fullName(stringMatcher):
            
            return AttributedStringBuilder()
                .text("Full name ", attributes: attributes.typeEmphasisAttributes)
                .attributedText( makeAttributedString(fromStringMatcher: stringMatcher, attributes: attributes) )
                .attributedString
            
        case let .parentContains(contentsMatcher):
            
            return AttributedStringBuilder()
                .text("Parent folder ", attributes: attributes.typeEmphasisAttributes)
                .text("contains ", attributes: attributes.regularAttributes)
                .attributedText( makeAttributedString(fromContentsMatcher: contentsMatcher, attributes: attributes) )
                .attributedString
            
        case let .parentDoesntContain(contentsMatcher):
            
            return AttributedStringBuilder()
                .text("Parent folder ", attributes: attributes.typeEmphasisAttributes)
                .text("doesn't contain ", attributes: attributes.regularAttributes)
                .attributedText( makeAttributedString(fromContentsMatcher: contentsMatcher, attributes: attributes) )
                .attributedString
            
        case let .hierarchyContains(hierarchyMatcher):
            
            return AttributedStringBuilder()
                .text("Hierarchy ", attributes: attributes.typeEmphasisAttributes)
                .text("contains ", attributes: attributes.regularAttributes)
                .attributedText( makeAttributedString(fromHierarchyMatcher: hierarchyMatcher, attributes: attributes))
                .attributedString
        }
    }
    
    private func makeAttributedString(fromStringMatcher stringMatcher: StringMatcher,
                                      attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        switch stringMatcher {
        case let .matching(string):
            return makeAttributedString(withRegularText: "is ", nameText: string, attributes: attributes)
        case let .notMatching(string):
            return makeAttributedString(withRegularText: "is not ", nameText: string, attributes: attributes)
        case let .containing(string):
            return makeAttributedString(withRegularText: "contains ", nameText: string, attributes: attributes)
        case let .notContaining(string):
            return makeAttributedString(withRegularText: "doesn't contain ", nameText: string, attributes: attributes)
        }
    }
    
    private func makeAttributedString(fromContentsMatcher contentsMatcher: FolderContentsMatcher,
                                      attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        switch contentsMatcher {
        case let .filesWithExtension(string):
            return makeAttributedString(withRegularText: "files with extension ",
                                        nameText: string,
                                        attributes: attributes)
        case let .filesWithFullName(string):
            return makeAttributedString(withRegularText: "file with full name ",
                                        nameText: string,
                                        attributes: attributes)
        case let .foldersWithName(string):
            return makeAttributedString(withRegularText: "folder with name ",
                                        nameText: string,
                                        attributes: attributes)
        }
    }
    
    private func makeAttributedString(fromHierarchyMatcher hierarchyMatcher: HierarcyMatcher,
                                      attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        func attrStringFromHierarchyStringMatcher(_ stringMatcher: StringMatcher,
                                                  attributes: ConditionFormatterAttributes) -> NSAttributedString {
            switch stringMatcher {
            case let .matching(string):
                return AttributedStringBuilder()
                    .text(string, attributes: attributes.nameEmphasisAttributes)
                    .attributedString
            default:
                fatalError("Not implemented")
            }
        }
        
        switch hierarchyMatcher {
        case let .folderWithName(stringMatcher):
            return AttributedStringBuilder()
                .text("folder with name ", attributes: attributes.regularAttributes)
                .attributedText(attrStringFromHierarchyStringMatcher(stringMatcher, attributes: attributes))
                .attributedString
        }
    }
    
    private func makeAttributedString(withRegularText regularText: String,
                                      nameText: String,
                                      attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        return AttributedStringBuilder()
            .text(regularText, attributes: attributes.regularAttributes)
            .text(nameText, attributes: attributes.nameEmphasisAttributes)
            .attributedString
    }
}
