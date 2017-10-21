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
        
        let attributes = RichTextAttributes(font: NSFont.systemFont(ofSize: 10),
                                            color: NSColor.black,
                                            boldFont: NSFont.systemFont(ofSize: 10),
                                            boldColor: NSColor.black)
        
        return attributedString(fromCondition: condition, withAttributes: attributes).string
    }
    
    func attributedString(fromCondition condition: FileRule.Condition,
                          withAttributes attributes: RichTextAttributes) -> NSAttributedString {
        
        switch condition {
        case let .name(stringMatcher):
            
            return AttributedStringBuilder()
                .text("Name ", attributes: attributes.italicAttributes)
                .attributedText( makeAttributedString(fromStringMatcher: stringMatcher, attributes: attributes) )
                .attributedString
            
        case let .ext(stringMatcher):
            
            return AttributedStringBuilder()
                .text("Extension ", attributes: attributes.italicAttributes)
                .attributedText( makeAttributedString(fromStringMatcher: stringMatcher, attributes: attributes) )
                .attributedString
            
        case let .fullName(stringMatcher):
            
            return AttributedStringBuilder()
                .text("Full name ", attributes: attributes.italicAttributes)
                .attributedText( makeAttributedString(fromStringMatcher: stringMatcher, attributes: attributes) )
                .attributedString
            
        case let .parentContains(contentsMatcher):
            
            return AttributedStringBuilder()
                .text("Parent folder ", attributes: attributes.italicAttributes)
                .text("contains ", attributes: attributes.regularAttributes)
                .attributedText( makeAttributedString(fromContentsMatcher: contentsMatcher, attributes: attributes) )
                .attributedString
            
        case let .parentDoesntContain(contentsMatcher):
            
            return AttributedStringBuilder()
                .text("Parent folder ", attributes: attributes.italicAttributes)
                .text("doesn't contain ", attributes: attributes.regularAttributes)
                .attributedText( makeAttributedString(fromContentsMatcher: contentsMatcher, attributes: attributes) )
                .attributedString
            
        case let .hierarchyContains(hierarchyMatcher):
            
            return AttributedStringBuilder()
                .text("Hierarchy ", attributes: attributes.italicAttributes)
                .text("contains ", attributes: attributes.regularAttributes)
                .attributedText( makeAttributedString(fromHierarchyMatcher: hierarchyMatcher, attributes: attributes))
                .attributedString
        }
    }
    
    private func makeAttributedString(fromStringMatcher stringMatcher: StringMatcher,
                                      attributes: RichTextAttributes) -> NSAttributedString {
        
        switch stringMatcher {
        case let .matching(string):
            return makeAttributedString(withRegularText: "is ", boldText: string, attributes: attributes)
        case let .notMatching(string):
            return makeAttributedString(withRegularText: "is not ", boldText: string, attributes: attributes)
        case let .containing(string):
            return makeAttributedString(withRegularText: "contains ", boldText: string, attributes: attributes)
        case let .notContaining(string):
            return makeAttributedString(withRegularText: "doesn't contain ", boldText: string, attributes: attributes)
        }
    }
    
    private func makeAttributedString(fromContentsMatcher contentsMatcher: FolderContentsMatcher,
                                      attributes: RichTextAttributes) -> NSAttributedString {
        
        switch contentsMatcher {
        case let .filesWithExtension(string):
            return makeAttributedString(withRegularText: "files with extension ",
                                        boldText: string,
                                        attributes: attributes)
        case let .filesWithFullName(string):
            return makeAttributedString(withRegularText: "file with full name ",
                                        boldText: string,
                                        attributes: attributes)
        case let .foldersWithName(string):
            return makeAttributedString(withRegularText: "folder with name ",
                                        boldText: string,
                                        attributes: attributes)
        }
    }
    
    private func makeAttributedString(fromHierarchyMatcher hierarchyMatcher: HierarcyMatcher,
                                      attributes: RichTextAttributes) -> NSAttributedString {
        
        func attrStringFromStringMatcher(_ stringMatcher: StringMatcher,
                                         attributes: RichTextAttributes) -> NSAttributedString {
            switch stringMatcher {
            case let .matching(string):
                return AttributedStringBuilder()
                    .text(string, attributes: attributes.boldAttributes)
                    .attributedString
            default:
                fatalError("Not implemented")
            }
        }
        
        switch hierarchyMatcher {
        case let .folderWithName(stringMatcher):
            return AttributedStringBuilder()
                .text("folder with name ", attributes: attributes.regularAttributes)
                .attributedText(attrStringFromStringMatcher(stringMatcher, attributes: attributes))
                .attributedString
        }
    }
    
    private func makeAttributedString(withRegularText regularText: String,
                                      boldText: String,
                                      attributes: RichTextAttributes) -> NSAttributedString {
        
        return AttributedStringBuilder()
            .text(regularText, attributes: attributes.regularAttributes)
            .text(boldText, attributes: attributes.boldAttributes)
            .attributedString
    }
}
