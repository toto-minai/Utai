//
//  SetupPage1.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

struct ImportView: View {
    @EnvironmentObject var store: Store
    
    // Drag and drop
    @State private var draggingOver = false
    @State private var droppedURLs: [URL] = []
    @State private var droppedGoal: Int?
    
    @State private var isConfirmSheetPresented = false
    
    var body: some View {
        let delegate = Delegate(draggingOver: $draggingOver,
                                urls: $droppedURLs,
                                goal: $droppedGoal)
        
        return ZStack {
            VStack(spacing: Metrics.lilSpacing2x) {
                WelcomeIcon()
                
                HStack(spacing: 2) {
                    Text("Drag or")
                        .fontWeight(.medium)
                    
                    ButtonCus(action: importFiles,
                              label: "Add Music",
                              systemName: "music.note")
                        .sheet(isPresented: $isConfirmSheetPresented, onDismiss: {}) {
                            ConfirmSheet(systemName: "music.note",
                                         instruction: "Might want to confirm the title and artists before searching on Discogs.",
                                         titles: Array(store.album!.albumTitleCandidates.sorted()),
                                         albumArtists: Array(store.album!.albumArtistsCandidates.sorted()))
                        }
                }
                
                Spacer()
            }
            .padding(.top, 59)  // Align with album artworks on search page
            // TODO: Make it clear how to calc
            
            if let goal = droppedGoal {
                if droppedURLs.count == goal {
                    void.onAppear {
                        store.album = Album(urls: droppedURLs)

                        if album.completed { store.didAlbumCompleted() }
                        else { isConfirmSheetPresented = true }
                    }
                }
            }
        }
        .frame(width: Metrics.unitLength, height: Metrics.unitLength)
        .onDrop(of: ["public.file-url"], delegate: delegate)
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
            print("Files not imported")
            return
        }
        
        store.album = Album(urls: panel.urls)
        
        if album.completed { store.didAlbumCompleted() }
        else { isConfirmSheetPresented = true }
    }
    
    struct Delegate: DropDelegate {
        @Binding var draggingOver: Bool
        @Binding var urls: [URL]
        @Binding var goal: Int?
        
        let performer = NSHapticFeedbackManager.defaultPerformer
        
        func dropEntered(info: DropInfo) {
            draggingOver = true
            NSApp.unhide(nil)
            performer.perform(.generic, performanceTime: .now)
        }
        
        func dropExited(info: DropInfo) {
            draggingOver = false
            performer.perform(.generic, performanceTime: .now)
        }

        func performDrop(info: DropInfo) -> Bool {
            let providers = info.itemProviders(for: ["public.file-url"])
            urls = []
            
            goal = providers.count
            for provider in providers {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, error in
                    guard let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil)
                    else { return }
                    
                    urls.append(url)
                }
            }
            
            return true
        }
    }
}

struct ConfirmSheet: View {
    @EnvironmentObject var store: Store
    
    let systemName: String
    let instruction: String
    
    @Environment(\.dismiss) var dismiss
    
    let titles: [String]
    let albumArtists: [String]
    
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
                ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                    Text(title).tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .foregroundColor(.secondary)
            .onAppear {
                if titles.count == 0 {
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
                ForEach(Array(albumArtists.enumerated()), id: \.offset) { index, artists in
                    Text(artists).tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .foregroundColor(.secondary)
            .onAppear {
                if albumArtists.count == 0 {
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
            
            Spacer().frame(height: Metrics.lilSpacing2x)
            
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
    private var album: Album { store.album! }
    
    private var canSearch: Bool {
        titleSelection != -1 ||
        artistsSelection != -1 ||
        titleSelection == -1 && titleCus != "" ||
        artistsSelection == -1 && artistsCus != ""
    }
    
    private func prepare() {
        store.album!.title = titleSelection == -1 ?
            (titleCus == "" ? nil : titleCus) :
            titles[titleSelection]
        
        store.album!.artists = artistsSelection == -1 ?
            (artistsCus == "" ? nil : artistsCus) :
            albumArtists[artistsSelection]
        
        store.didAlbumCompleted()
        
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
