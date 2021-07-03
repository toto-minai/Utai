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
        WindowGroup { }
            .windowStyle(.hiddenTitleBar)
            // Disable Command-N to create a new window
            .commands { CommandGroup(replacing: .newItem, addition: {}) }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    @AppStorage("launchForTheFirstTime") var launchForTheFirstTime: Bool = true
    
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hijack main window created by Scene
        NSApp.windows.first!.close()
        
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 312, height: 312),
                          styleMask: [.titled, .closable, .fullSizeContentView],
                          backing: .buffered, defer: false)
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        window.level = .floating
        window.tabbingMode = .disallowed
        
        let contentView = WrappedContentView()
            .environment(\.hostingWindow, { [weak window] in
            return window
        })
        window.contentView = NSHostingView(rootView: contentView)
        window.setFrameAutosaveName("Utai Main Window")
        
        if launchForTheFirstTime {
            window.center()
            
            launchForTheFirstTime = false
        }
        
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { false }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

// Access window in Views
struct HostingWindowKey: EnvironmentKey {
    typealias Value = () -> NSWindow?
    
    static let defaultValue: Self.Value = { nil }
}

extension EnvironmentValues {
    var hostingWindow: HostingWindowKey.Value {
        get { self[HostingWindowKey.self] }
        set { self[HostingWindowKey.self] = newValue }
    }
}
