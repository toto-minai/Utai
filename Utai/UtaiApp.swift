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
            // Disable Command-N to create a new window
            .commands { CommandGroup(replacing: .newItem, addition: {}) }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @AppStorage("launchForTheFirstTime") var launchForTheFirstTime: Bool = true
    
    var window: NSWindow!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        #if CLEAN_APPSTORAGE
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        #endif
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hijack main window created by Scene
        window = NSApp.windows.first!
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        window.level = .floating
        window.tabbingMode = .disallowed
        
        window.delegate = self
        
        let contentView = WrappedContentView()
            .environment(\.hostingWindow, { [weak window] in
            return window
        })
        window.contentView = NSHostingView(rootView: contentView)
        
        if launchForTheFirstTime {
            window.center()
            
            launchForTheFirstTime = false
        }
        
        window.makeKeyAndOrderFront(nil)
    }
    
    func windowWillClose(_ notification: Notification) { NSApp.terminate(self) }
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
