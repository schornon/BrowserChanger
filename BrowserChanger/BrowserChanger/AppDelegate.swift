//
//  AppDelegate.swift
//  BrowserChanger
//
//  Created by Sergey Chernonog on 10/2/19.
//  Copyright © 2019 Sergey Chernonog. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
  
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
  let menu = NSMenu()
  var browsersList : [String: String] = [:]
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    menu.delegate = self
    menu.autoenablesItems = false
    
    if let button = statusItem.button {
      button.image = NSImage(named: NSImage.Name("tambourine"))
    }

    constructMenu()
    addQuitTabToMenu()
  }
  
  func menuWillOpen(_ menu: NSMenu) {
    let inURLScheme = "http" as CFString
    guard let defaultBrowserBundle = LSCopyDefaultHandlerForURLScheme(inURLScheme)?.takeRetainedValue() as String? else { return }
    let defaultBrowserName = getBrowserName(bundle: defaultBrowserBundle)
    if defaultBrowserName != nil {
      for item in menu.items {
        if item.title == defaultBrowserName {
          print(item.title)
          item.isEnabled = false
        } else {
          item.isEnabled = true
        }
      }
    }
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  private func constructMenu() {
    let inURLScheme = "http" as CFString
    
    guard
      let handlersForHTTPUnmanaged = LSCopyAllHandlersForURLScheme(inURLScheme),
      let handlersForHTTP = handlersForHTTPUnmanaged.takeRetainedValue() as? [String] else {
        return
    }
    
    for bundle in handlersForHTTP {
      if !bundle.contains("iterm2") && !bundle.contains("BrowserChanger") {
        let browserName = getBrowserName(bundle: bundle)
        if browserName != nil {
          menu.addItem(withTitle: browserName!, action: #selector(setDefaultBrowser(_:)), keyEquivalent: browserName!)
          browsersList[browserName!] = bundle
        }
      }
    }
  }
  
  private func addQuitTabToMenu() {
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    
    statusItem.menu = menu
  }
  
  @objc func setDefaultBrowser(_ sender: NSMenuItem) {
    print("set \(sender.title) as Default Browser")
    guard let bundleID = browsersList[sender.title] else { return }
    let inURLScheme = "http" as CFString
    let inHandlerBundleID = bundleID as CFString
    LSSetDefaultHandlerForURLScheme(inURLScheme, inHandlerBundleID)
  }
  
  private func getBrowserName(bundle: String) -> String? {
    let split = bundle.split(separator: ".")
    if split.count > 0 {
      let browserName = String(split.last!)
      return browserName.capitalized
    }
    return nil
  }
  
}

/// NSWorkspace.shared.runningApplications.forEach { print($0.bundleIdentifier) }

/// com.apple.Safari
/// com.google.Chrome
/// com.operasoftware.Opera
/// org.mozilla.firefox
