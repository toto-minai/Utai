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
    @State private var isConfirmPresented = false
    
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
        
        if !store.album!.completed {
            isConfirmPresented = true
        }
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
        .sheet(isPresented: $isConfirmPresented, onDismiss: {}) {
            ConfirmSheet()
        }
    }
}

struct ConfirmSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    
    @State private var albumTitleSelection: Int = 0
    @State var albumTitleCustom: String = ""
    @FocusState private var albumTitleCustomFocused: Bool
    
    @State private var albumArtistsSelection: Int = 0
    @State var albumArtistsCustom: String = ""
    @FocusState private var albumArtistsCustomFocused: Bool
    
    private func prepareSearching() {
        store.album!.title = albumTitleSelection == -1 ?
            albumTitleCustom :
            Array(store.album!.albumTitleCandidates)[albumTitleSelection]
        
        store.album!.title = albumArtistsSelection == -1 ?
            albumTitleCustom :
            Array(store.album!.albumArtistsCandidates)[albumArtistsSelection]
        
        // TODO: Search on Discogs
        
        dismiss()
    }
    
    var body: some View {
        Form {
            Text("Might want to confirm the title and artists before searching on Discogs.")
            Divider()
            
            Spacer()
            
            Picker("Album:", selection: $albumTitleSelection) {
                ForEach(0..<store.album!.albumTitleCandidates.count) { index in
                    Text("\(Array(store.album!.albumTitleCandidates)[index])")
                        .tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .onAppear {
                if store.album!.albumTitleCandidates.count == 0 {
                    albumTitleSelection = -1
                    albumTitleCustomFocused = true
                }
            }
            .onChange(of: albumTitleSelection) { value in
                if value == -1 {
                    albumTitleCustomFocused = true
                }
            }
            
            TextField("", text: $albumTitleCustom)
                // .textFieldStyle(.roundedBorder) // Bad looking
                .disabled(albumTitleSelection != -1)
                .focused($albumTitleCustomFocused)
            
            Picker("Artist(s):", selection: $albumArtistsSelection) {
                ForEach(0..<store.album!.albumArtistsCandidates.count) { index in
                    Text("\(Array(store.album!.albumArtistsCandidates)[index])")
                        .tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .onAppear {
                if store.album!.albumArtistsCandidates.count == 0 {
                    albumArtistsSelection = -1
                    albumArtistsCustomFocused = true
                }
            }
            .onChange(of: albumArtistsSelection) { value in
                if value == -1 {
                    albumArtistsCustomFocused = true
                }
            }
            
            TextField("", text: $albumArtistsCustom)
                // .textFieldStyle(.roundedBorder) // Bad looking
                .disabled(albumArtistsSelection != -1)
                .focused($albumArtistsCustomFocused)
            
            Spacer().frame(height: 16)
            
            HStack {
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Cancel")
                }
                .buttonStyle(.borderless)
                
                Button(action: prepareSearching) {
                    Text("**Search**")
                }
                .controlProminence(.increased)
            }
        }
        .padding([.leading, .top], 16)
        .padding([.trailing, .bottom], 8)
        .frame(width: 256, height: 256)
    }
}
