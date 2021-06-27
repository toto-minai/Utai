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
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hijack main window created by Scene
        window = NSApp.windows.first!
        window.orderOut(nil)
        
        // TODO: Should only set frame for the first time
        window.setFrame(NSRect(x: 0, y: 0, width: 312, height: 312), display: true)
        window.styleMask.remove([.miniaturizable])
        
        window.titleVisibility = .hidden
        window.setFrameAutosaveName("Utai Main Window")
        
        window.titlebarAppearsTransparent = true
        window.level = .floating
        window.tabbingMode = .disallowed
        
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        let contentView = WrappedContentView()
            .environment(\.hostingWindow, { [weak window] in
            return window!
        })
        window.contentView = NSHostingView(rootView: contentView)
        
        // TODO: Should only centering window for the first time
        // window.center()
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Save frame, in case it didn't
        let frame = window.frame
        window.setFrame(NSRect(x: frame.minX, y: frame.maxY-312, width: 312, height: 312), display: false)
        window.saveFrame(usingName: "Utai Main Window")
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
        get { return self[HostingWindowKey.self] }
        set { self[HostingWindowKey.self] = newValue }
    }
}
