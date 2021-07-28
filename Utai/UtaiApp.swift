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
            .commands {
                // Remove default Open
                CommandGroup(replacing: .newItem, addition: {})
                
                CommandGroup(replacing: .appInfo) {
                    Button("About Utai") {
                        appDelegate.showAboutWindow()
                    }
                }
                
                CommandGroup(replacing: .help) {
                    Button("Cookbook") {
                        print("Cookbook")
                    }
                }
                
                ViewCommands()
            }
    }
}

struct ViewCommands: Commands {
    var body: some Commands {
        CommandMenu("View") {
            Menu("Pages") {
                Button("Import") {
                    NotificationCenter.default.post(name: Notification.Name("turnToPage1"),
                                                    object: nil)
                }.keyboardShortcut("1")
                
                Button("Choose") {
                    NotificationCenter.default.post(name: Notification.Name("turnToPage2"),
                                                    object: nil)
                }.keyboardShortcut("2")
                
                Button("Match") {
                    NotificationCenter.default.post(name: Notification.Name("turnToPage3"),
                                                    object: nil)
                }.keyboardShortcut("3")
            }
            
            Divider()
            
            Button("Show Options") {
                NotificationCenter.default.post(name: Notification.Name("showOptions"),
                                                object: nil)
            }.keyboardShortcut(".", modifiers: .command)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var window: NSWindow!
    var aboutWindow: NSWindow!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        #if CLEAN_APPSTORAGE
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        #endif
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hijack main window created by WindowGroup
        window = NSApp.windows.first!
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        #if SCREENSHOT_MODE
        window.backgroundColor = .clear
        window.hasShadow = false
        #endif
        
        window.level = .floating
        window.tabbingMode = .disallowed
        
        window.delegate = self
        
        // Passing hosting window to ContentView()
        let contentView = WrappedContentView()
            .environment(\.hostingWindow, { [weak window] in
                return window
            })
        window.contentView = NSHostingView(rootView: contentView)
        
        if isFirstLaunch {
            window.center()
            
            isFirstLaunch = false
        }
        
        window.makeKeyAndOrderFront(nil)
        
        buildAboutWindow()
    }
    
    // Quit the app when main window is closed
    func windowWillClose(_ notification: Notification) { NSApp.terminate(self) }
    
    func showAboutWindow() {
        aboutWindow.center()
        aboutWindow.makeKeyAndOrderFront(nil)
    }
    
    private func buildAboutWindow() {
        aboutWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: Metrics.unitLength, height: Metrics.unitLength),
                               styleMask: [.titled, .closable, .fullSizeContentView],
                               backing: .buffered, defer: false)
        aboutWindow.titleVisibility = .hidden
        aboutWindow.titlebarAppearsTransparent = true
        aboutWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        aboutWindow.standardWindowButton(.zoomButton)?.isHidden = true
        
        aboutWindow.level = .floating
        aboutWindow.isMovableByWindowBackground = true
        
        aboutWindow.contentView = NSHostingView(rootView: About())
    }
}

// Allow window access in Views
struct HostingWindowKey: EnvironmentKey {
    static let defaultValue: () -> NSWindow? = { nil }
}

extension EnvironmentValues {
    var hostingWindow: () -> NSWindow? {
        get { self[HostingWindowKey.self] }
        set { self[HostingWindowKey.self] = newValue }
    }
}
