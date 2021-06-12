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
    
    @State private var titleSelection: Int = 0
    @State var titleCus: String = ""
    @FocusState private var titleCusFocused: Bool
    
    @State private var artistsSelection: Int = 0
    @State var artistsCus: String = ""
    @FocusState private var artistsCusFocused: Bool
    
    private func prepareSearching() {
        store.album!.title = titleSelection == -1 ?
            titleCus :
            Array(store.album!.albumTitleCandidates)[titleSelection]
        
        store.album!.title = artistsSelection == -1 ?
            titleCus :
            Array(store.album!.albumArtistsCandidates)[artistsSelection]
        
        // TODO: Search on Discogs
        
        dismiss()
    }
    
    var body: some View {
        Form {
            Text("I½. Might want to confirm the title and artists before searching on Discogs.")
            Divider()
            
            Spacer()
            
            Picker("Album:", selection: $titleSelection) {
                ForEach(0..<store.album!.albumTitleCandidates.count) { index in
                    Text("\(Array(store.album!.albumTitleCandidates)[index])")
                        .tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .onAppear {
                if store.album!.albumTitleCandidates.count == 0 {
                    titleSelection = -1
                    titleCusFocused = true
                }
            }
            .onChange(of: titleSelection) { value in
                if value == -1 { titleCusFocused = true }
            }
            
            TextField("", text: $titleCus)
                // .textFieldStyle(.roundedBorder) // Bad looking
                .disabled(titleSelection != -1)
                .focused($titleCusFocused)
            
            Picker("Artist(s):", selection: $artistsSelection) {
                ForEach(0..<store.album!.albumArtistsCandidates.count) { index in
                    Text("\(Array(store.album!.albumArtistsCandidates)[index])")
                        .tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .onAppear {
                if store.album!.albumArtistsCandidates.count == 0 {
                    artistsSelection = -1
                    artistsCusFocused = true
                }
            }
            .onChange(of: artistsSelection) { value in
                if value == -1 { artistsCusFocused = true }
            }
            
            TextField("", text: $artistsCus)
                // .textFieldStyle(.roundedBorder) // Bad looking
                .disabled(artistsSelection != -1)
                .focused($artistsCusFocused)
            
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
