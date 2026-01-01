//
//  AppDelegate.swift
//  CryptoApp
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create main window
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "CryptoApp - File Encryption"
        window.center()
        window.setFrameAutosaveName("Main Window")
        
        // Create view controller
        let viewController = ViewController()
        window.contentViewController = viewController
        
        self.window = window
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminateNotification(_ aNotification: Notification) {
        // Save data if needed
    }
}
