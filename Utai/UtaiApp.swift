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
    var testWindow: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApp.windows.first {  // TODO: Not working when reopening a window
            let contentView = WrappedContentView().environment(\.hostingWindow, { [weak window] in
                return window!
            })
            
            window.contentView = NSHostingView(rootView: contentView)
            
//            window.isMovableByWindowBackground = true
            window.level = .floating
            
            window.styleMask.remove(.miniaturizable)
            window.styleMask.remove(.fullScreen)

            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
    }
}

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

