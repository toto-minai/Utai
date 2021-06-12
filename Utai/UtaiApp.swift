//
//  UtaiApp.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/09.
//

import SwiftUI

@main
struct UtaiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView().colorScheme(.dark)
                .environmentObject(store)
        }
        .windowStyle(.hiddenTitleBar)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApp.windows.first {
            window.isMovableByWindowBackground = true
            window.level = .floating
            
            window.styleMask.remove(.miniaturizable)
            window.styleMask.remove(.fullScreen)

            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
    }
}
