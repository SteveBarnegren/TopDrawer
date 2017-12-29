//
//  MockIconProvider.swift
//  TopDrawerTests
//
//  Created by Steve Barnegren on 29/12/2017.
//  Copyright © 2017 SteveBarnegren. All rights reserved.
//

import Foundation
import AppKit
@testable import TopDrawer

class MockIconProvider: IconProvider {
    
    func icon(forPath path: String) -> NSImage {
        return NSImage()
    }
}
