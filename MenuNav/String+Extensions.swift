//
//  String+Extensions.swift
//  MenuNav
//
//  Created by Steve Barnegren on 28/04/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation

extension String {
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    func deletingPathExtension() -> String {
        return (self as NSString).deletingPathExtension
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
}
