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
    
    var body: some Scene {
        WindowGroup {}
            .windowStyle(.hiddenTitleBar)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Close original window
        if let window = NSApp.windows.first { window.close() }
        
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 312, height: 312),
                          styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        
        let contentView = WrappedContentView()
            .environment(\.hostingWindow, { [weak window] in
            return window!
        })
        
        window.setFrameAutosaveName("Main Window")
        
        window.titlebarAppearsTransparent = true
        window.level = .floating
        
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        window.contentView = NSHostingView(rootView: contentView)
        
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}

// Access window in Views
struct HostingWindowKey: EnvironmentKey {
    typealias Value = () -> NSWindow?
    
    static let defaultValue: Self.Value = { nil }
}

extension EnvironmentValues {
    var hostingWindow: HostingWindowKey.Value {
        get { return self[HostingWindowKey.self] }
        set { self[HostingWindowKey.self] = newValue }
    }
}

