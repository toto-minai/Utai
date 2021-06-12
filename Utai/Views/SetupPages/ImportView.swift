//
//  SetupPage1.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

struct ImportView: View {
    @EnvironmentObject var store: Store
    
    @State private var dragOver = false
    
    private func importFile() {
        let panel = NSOpenPanel()
        panel.title = "Add Music"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        
        guard panel.runModal() == .OK else {
            print("Error on open panel")
            return
        }
        
        store.album = Album(urls: panel.urls)
    }
    
    var body: some View {
        return ZStack {
            VStack {
                Text("I. **Import**")
                
                Spacer()
            }
            .padding(.top, 8)
            
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .foregroundColor(Color.black.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image("SimpleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54)
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                HStack(spacing: 2) {
                    Text("**Drag** or")
                    
                    Button(action: importFile) {
                        Text("**Add Music**")
                    }
                    .buttonStyle(.borderless)
                }
            }
            .offset(y: -8)
            
            
        }
        .frame(width: unitLength, height: unitLength)
    }
}
