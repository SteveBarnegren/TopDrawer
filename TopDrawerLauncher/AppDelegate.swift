//
//  AppDelegate.swift
//  TopDrawerLauncher
//
//  Created by Nicolas Degen on 15.03.19.
//  Copyright © 2019 SteveBarnegren. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  let mainAppIdentifier = "com.stevebarnegren.topdrawer"
  
  @objc func terminate() {
    NSApp.terminate(nil)
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    let runningApps = NSWorkspace.shared.runningApplications
    let isRunning = runningApps.contains { $0.bundleIdentifier == mainAppIdentifier }
    
    if !isRunning {
      DistributedNotificationCenter.default().addObserver(self,
                                                          selector: #selector(self.terminate),
                                                          name: .killLauncher,
                                                          object: mainAppIdentifier)
      
      let path = Bundle.main.bundlePath as NSString
      var components = path.pathComponents
      components.removeLast()
      components.removeLast()
      components.removeLast()
      components.append("MacOS")
      components.append("TopDrawer")
      
      let topDrawerAppPath = NSString.path(withComponents: components)
      
      NSWorkspace.shared.launchApplication(topDrawerAppPath)
    } else {
      self.terminate()
    }
  }
}
