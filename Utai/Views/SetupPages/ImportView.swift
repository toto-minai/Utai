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
        store.searchResult = nil
        
        let panel = NSOpenPanel()
        panel.title = "􀑪 Add Music"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        
        guard panel.runModal() == .OK else {
            print("Error on open panel")
            return
        }
        
        store.album = Album(urls: panel.urls)
        
        if !store.album!.completed {
            isConfirmPresented = true
        } else {
            withAnimation(.spring()) {
                store.page = 2
            }
        }
    }
    
    var body: some View {
        return VStack(spacing: 0) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .foregroundColor(Color.black.opacity(0.2))
                        .frame(width: 110, height: 110)
                    
                    Image("SimpleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 54)
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                HStack(spacing: 2) {
                    Text("**Drag** or")
                    
                    Button(action: importFile) {
                        HStack(spacing: 0) {
                            Image(systemName: "music.note")
                                .font(.system(size: 12))
                                .offset(y: -1.2)
                            Text("**Add Music**")
                        }
                    }
                    .buttonStyle(.borderless)
                    .focusable(false)
                    .shadow(radius: 3)
                }
            }
            .offset(y: 59)
            
            Spacer()
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
    
    var canSearch: Bool {
        titleSelection != -1 ||
        artistsSelection != -1 ||
        titleSelection == -1 && titleCus != "" ||
        artistsSelection == -1 && artistsCus != ""
    }
    
    private func prepareSearching() {
        store.album!.title = titleSelection == -1 ?
            (titleCus == "" ? nil : titleCus) :
            Array(store.album!.albumTitleCandidates)[titleSelection]
        
        store.album!.artists = artistsSelection == -1 ?
            (artistsCus == "" ? nil : artistsCus) :
            Array(store.album!.albumArtistsCandidates)[artistsSelection]
        
        withAnimation(.spring()) {
            store.page = 2
        }
        
        dismiss()
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "music.note")
                .font(.system(size: 12))
                .padding(8)
            
            Form {
                Group {
                    Text("Might want to confirm the title and artists before searching on Discogs.")
                    Divider()
                }.offset(y: 1.2)
                
                Spacer()
                
                Picker("**Album**", selection: $titleSelection) {
                    ForEach(0..<store.album!.albumTitleCandidates.count) { index in
                        Text("\(Array(store.album!.albumTitleCandidates)[index])")
                            .tag(index)
                    }
                    Divider()
                    Text("Other…").tag(-1)
                }
                .foregroundColor(.secondary)
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
                
                Picker("**Artist(s)**", selection: $artistsSelection) {
                    ForEach(0..<store.album!.albumArtistsCandidates.count) { index in
                        Text("\(Array(store.album!.albumArtistsCandidates)[index])")
                            .tag(index)
                    }
                    Divider()
                    Text("Other…").tag(-1)
                }
                .foregroundColor(.secondary)
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
                    .disabled(!canSearch)
                }
            }
            .padding([.leading], 16)
            .padding([.trailing, .bottom, .top], 8)
            .frame(width: 256, height: 256)
        }
    }
}
