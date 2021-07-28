//
//  Commands.swift
//  Commands
//
//  Created by Toto Minai on 2021/07/28.
//

import SwiftUI

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
            
            Button("Toggle Options") {
                NotificationCenter.default.post(name: Notification.Name("toggleOptions"),
                                                object: nil)
            }.keyboardShortcut(".")
        }
    }
}
