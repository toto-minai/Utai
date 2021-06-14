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
    
    @State private var newAlbum: Album?
    @State private var isConfirmPresented = false
    @State private var urls: [URL] = []
    
    var body: some View {
        let delegate = MusicDropDelegate(urls: $urls, goal: $store.goal, dropOver: $dragOver)
        
        return VStack(spacing: 0) {
            VStack(spacing: lilSpacing2x) {
                WelcomeIcon()
                
                HStack(spacing: 2) {
                    Text("Drag or")
                    
                    ButtonCus(action: importFiles,
                              label: "Add Music",
                              systemName: "music.note")
                        .sheet(isPresented: $isConfirmPresented, onDismiss: {}) {
                            ConfirmSheet(newAlbum: $newAlbum, systemName: "music.note",
                                         instruction:
                                "Might want to confirm the title and artists before searching on Discogs.")
                        }
                }
            }
            .offset(y: 59)  // Align with album artworks on search page
            // TODO: Make it clear how to calc
            
            Spacer()
            
            if let goal = store.goal {
                if urls.count == goal {
                    Spacer().frame(height: 0)
                        .onAppear {
                            let anAlbum = Album(urls: urls)
                            
                            urls = []

                            if anAlbum.completed {
                                store.album = anAlbum
                                store.showMatchPanel = true
                                store.makeSearchUrl()
                                store.page = 2
                            } else {
                                newAlbum = anAlbum
                                isConfirmPresented = true
                            }
                        }
                }
            }
        }
        .frame(width: unitLength, height: unitLength)
        .onDrop(of: ["public.file-url"], delegate: delegate)
    }
}

struct MusicDropDelegate: DropDelegate {
    @Binding var urls: [URL]
    @Binding var goal: Int?
    @Binding var dropOver: Bool
    
    let performer = NSHapticFeedbackManager.defaultPerformer
    
    func dropEntered(info: DropInfo) {
        dropOver = true
        performer.perform(.generic, performanceTime: .now)
    }
    
    func dropExited(info: DropInfo) {
        dropOver = false
        performer.perform(.generic, performanceTime: .now)
    }

    func performDrop(info: DropInfo) -> Bool {
        let providers = info.itemProviders(for: ["public.file-url"])
        
        goal = providers.count
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                urls.append(url)
            }
        }
        
        return true
    }
}

extension ImportView {
    private var album: Album { store.album! }
    
    private func importFiles() {
        let panel = NSOpenPanel()
        panel.title = "􀑪 Add Music"
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        
        guard panel.runModal() == .OK else {
            print("Error on open panel")
            return
        }
        
        let anAlbum = Album(urls: panel.urls)
        
        if anAlbum.completed {
            store.album = anAlbum
            store.showMatchPanel = true
            store.makeSearchUrl()
            store.page = 2
        } else {
            newAlbum = anAlbum
            isConfirmPresented = true
        }
    }
}

struct ConfirmSheet: View {
    @EnvironmentObject var store: Store
    
    @Binding var newAlbum: Album?
    
    let systemName: String
    let instruction: String
    
    @Environment(\.dismiss) var dismiss
    
    @State private var titleSelection: Int = 0
    @State var titleCus: String = ""
    @FocusState private var titleCusFocused: Bool
    
    @State private var artistsSelection: Int = 0
    @State var artistsCus: String = ""
    @FocusState private var artistsCusFocused: Bool
    
    var body: some View {
        Form {
            Group {
                Text(instruction)
                    .lineSpacing(4)
                Divider()
            }.offset(y: 1.2)
            
            Spacer()
            
            Picker("**Album**", selection: $titleSelection) {
                ForEach(0..<album.albumTitleCandidates.count) { index in
                    Text("\(Array(album.albumTitleCandidates)[index])")
                        .tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .foregroundColor(.secondary)
            .onAppear {
                if album.albumTitleCandidates.count == 0 {
                    titleSelection = -1
                    titleCusFocused = true
                }
            }
            .onChange(of: titleSelection) { value in
                if value == -1 { titleCusFocused = true }
            }
            
            TextField("", text: $titleCus)
                .disabled(titleSelection != -1)
                .focused($titleCusFocused)
            
            Picker("**Artist(s)**", selection: $artistsSelection) {
                ForEach(0..<album.albumArtistsCandidates.count) { index in
                    Text("\(Array(album.albumArtistsCandidates)[index])")
                        .tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .foregroundColor(.secondary)
            .onAppear {
                if album.albumArtistsCandidates.count == 0 {
                    artistsSelection = -1
                    artistsCusFocused = true
                }
            }
            .onChange(of: artistsSelection) { value in
                if value == -1 { artistsCusFocused = true }
            }
            
            TextField("", text: $artistsCus)
                .disabled(artistsSelection != -1)
                .focused($artistsCusFocused)
            
            Spacer().frame(height: lilSpacing2x)
            
            HStack {
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Cancel")
                }
                .buttonStyle(.borderless)
                
                Button(action: prepare) {
                    Text("**Search**")
                }
                .controlProminence(.increased)
                .disabled(!canSearch)
            }
        }
        .modifier(ConfigureSheet(systemName: systemName))
    }
}

extension ConfirmSheet {
    private var album: Album { newAlbum! }
    
    private var canSearch: Bool {
        titleSelection != -1 ||
        artistsSelection != -1 ||
        titleSelection == -1 && titleCus != "" ||
        artistsSelection == -1 && artistsCus != ""
    }
    
    private func prepare() {
        store.album = album
        store.album!.title = titleSelection == -1 ?
            (titleCus == "" ? nil : titleCus) :
            Array(album.albumTitleCandidates)[titleSelection]
        
        store.album!.artists = artistsSelection == -1 ?
            (artistsCus == "" ? nil : artistsCus) :
            Array(album.albumArtistsCandidates)[artistsSelection]
        
        store.showMatchPanel = true
        store.makeSearchUrl()
        store.page = 2
        
        dismiss()
    }
}

struct WelcomeIcon: View {
    var body: some View {
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
    }
}
