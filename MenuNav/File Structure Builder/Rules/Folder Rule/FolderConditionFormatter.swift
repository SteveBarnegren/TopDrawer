//
//  FolderConditionFormatter.swift
//  MenuNav
//
//  Created by Steve Barnegren on 09/08/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit
import AttributedStringBuilder

class FolderConditionFormatter {
    
    // MARK: - Strings from conditions
    
    func string(fromCondition condition: FolderRule.Condition) -> String {
        
        // Returns a non-attributed string, so these attrbutes will be stipped out
        let attributes = ConditionFormatterAttributes.standard
        return attributedString(fromCondition: condition, withAttributes: attributes).string
    }
    
    func attributedString(fromCondition condition: FolderRule.Condition,
                          withAttributes attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        switch condition {
        case let .path(pathMatcher):
            
            return AttributedStringBuilder()
                .text("Path ", attributes: attributes.typeEmphasisAttributes)
                .attributedText( makeAttributedString(pathMatcher: pathMatcher, attributes: attributes) )
                .attributedString
            
        case let .name(stringMatcher):
            
            return AttributedStringBuilder()
                .text("Name ", attributes: attributes.typeEmphasisAttributes)
                .attributedText( makeAttributedString(stringMatcher: stringMatcher, attributes: attributes) )
                .attributedString
            
        case let .contains(contentsMatcher):
            
            return AttributedStringBuilder()
                .text("Contains ", attributes: attributes.typeEmphasisAttributes)
                .attributedText( makeAttributedString(contentsMatcher: contentsMatcher, attributes: attributes) )
                .attributedString
            
        case let .doesntContain(contentsMatcher):
            
            return AttributedStringBuilder()
                .text("Doesn't contain ", attributes: attributes.typeEmphasisAttributes)
                .attributedText( makeAttributedString(contentsMatcher: contentsMatcher, attributes: attributes) )
                .attributedString
        }
    }
    
    private func makeAttributedString(pathMatcher: PathMatcher,
                                      attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        switch pathMatcher {
        case let .matching(string):
            
            return AttributedStringBuilder()
                .text("is ", attributes: attributes.regularAttributes)
                .text(string, attributes: attributes.nameEmphasisAttributes)
                .attributedString
            
        case let .notMatching(string):
            
            return AttributedStringBuilder()
                .text("is not ", attributes: attributes.regularAttributes)
                .text(string, attributes: attributes.nameEmphasisAttributes)
                .attributedString
        }
    }
    
    private func makeAttributedString(stringMatcher: StringMatcher,
                                      attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        let prefix: String
        
        switch stringMatcher {
        case .matching: prefix = "is"
        case .notMatching: prefix = "is not"
        case .containing: prefix = "contains"
        case .notContaining: prefix = "doesn't contain"
        }
        
        return AttributedStringBuilder()
            .text(prefix, attributes: attributes.regularAttributes)
            .space()
            .text(stringMatcher.string, attributes: attributes.nameEmphasisAttributes)
            .attributedString
    }
    
    private func makeAttributedString(contentsMatcher: FolderContentsMatcher,
                                      attributes: ConditionFormatterAttributes) -> NSAttributedString {
        
        let prefix: String
        let value: String
        
        switch contentsMatcher {
        case let .filesWithExtension(ext):
            prefix = "files with extension"
            value = ext
        case let .filesWithFullName(name):
            prefix = "file"
            value = name
        case let .foldersWithName(name):
            prefix = "folder with name"
            value = name
        }
        
        return AttributedStringBuilder()
            .text(prefix, attributes: attributes.regularAttributes)
            .space()
            .text(value, attributes: attributes.nameEmphasisAttributes)
            .attributedString
    }
}
