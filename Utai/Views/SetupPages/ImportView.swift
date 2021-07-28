//
//  SetupPage1.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

struct ImportView: View {
    @EnvironmentObject var store: Store
    
    @AppStorage(Settings.alwaysConfirm) var alwaysConfirm: Bool = false
    @AppStorage(Settings.pageTurnerIconType) var pageTurner: Int = 1
    
    // Drag and drop
    @State private var draggingOver = false
    @State private var importedURLs: [URL] = []
    @State private var importGoal: Int?
    
    @State private var isConfirmSheetPresented = false
    
    @FocusState private var isOptionsFocused: Bool
    
    private var welcomeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .foregroundColor(Color.black.opacity(0.2))
                .frame(width: 109, height: 109)
            
            Image("SimpleIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 45)
                .foregroundColor(Color.secondary)
        }
    }
    
    private var main: some View {
        HStack(spacing: 2) {
            Text("Drag or")
                .fontWeight(.medium)
            
            ButtonCus(action: add,
                      label: "Add Music",
                      systemName: "music.note")
                .keyboardShortcut("o", modifiers: .command)
                .disabled(store.page != 1)
                .sheet(isPresented: $isConfirmSheetPresented) {
                    ConfirmSheet(systemName: "music.note",
                                 instruction: "Confirm the title and artists before searching on Discogs.",
                                 albums: unit.albumCandidatesSorted,
                                 artists: unit.artistCandidatesSorted)
                }
        }
    }
    
    private var extraMenu: some View {
        Group {
            Section("Preferences") {
                Toggle("Always Confirm Album", isOn: $alwaysConfirm)
                
                Picker("Page-Turner", selection: $pageTurner) {
                    Text("􀀁􀛤􀂓").tag(1)
                    Text("􀀁􀁑􀀿").tag(2)
                }
            }
        }
    }
    
    private var footer: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Menu { extraMenu } label: {
                    ButtonMini(alwaysHover: true,
                               systemName: "ellipsis.circle",
                               helpText: "Options")
                        .padding(Metrics.lilSpacing)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuIndicator(.hidden)
                .help("Options (⌘ , )")
                .frame(width: Metrics.lilSpacing2x+Metrics.lilIconLength,
                       height: Metrics.lilSpacing2x+Metrics.lilIconLength)
                .offset(x: 2, y: -0.5)
                .focused($isOptionsFocused)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("showOptions"))) { _ in
                    isOptionsFocused = true
                    
                    let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
                    let spaceKey: UInt16 = 49
                    
                    let spaceDown = CGEvent(keyboardEventSource: source, virtualKey: spaceKey, keyDown: true)
                    let spaceUp = CGEvent(keyboardEventSource: source, virtualKey: spaceKey, keyDown: false)
                    spaceDown?.flags = .maskNonCoalesced
                    spaceUp?.flags = .maskNonCoalesced
                    
                    let tap = CGEventTapLocation.cghidEventTap
                    spaceDown?.post(tap: tap)
                    spaceUp?.post(tap: tap)
                }
            }
        }
    }
    
    var body: some View {
        let delegate = Delegate(draggingOver: $draggingOver,
                                urls: $importedURLs,
                                goal: $importGoal)
        
        return ZStack {
            if store.page == 1 {
                Button("") { }
                    .keyboardShortcut(.tab, modifiers: [])
                    .hidden()
            }
            
            VStack(spacing: Metrics.lilSpacing) {
                welcomeIcon
                
                main
                
                Spacer()
            }
            .padding(.top, 57)  // Align with album artworks on search page
            // TODO: Make it clear how to calc
            
            if store.page == 1 {
                footer
            }
            
            // Do when collected all dropped URLs
            if let goal = importGoal {
                if importedURLs.count == goal {
                    void.onAppear {
                        store.localUnit = LocalUnit(urls: importedURLs)
                        
                        importedURLs = []  // Reset for another drop
                            
                        if unit.isQueryComplete && !alwaysConfirm { store.willSearch() }
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
    private var unit: LocalUnit { store.localUnit! }
    
    // TODO: Might want to use a SwiftUI version to open files
    private func add() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.audio]  // TODO: Should show alert if not .mp3
        
        guard panel.runModal() == .OK else {
            print("Files not imported")
            return
        }
        
        store.localUnit = LocalUnit(urls: panel.urls)
        
        if unit.isQueryComplete && !alwaysConfirm { store.willSearch() }
        else { isConfirmSheetPresented = true }
    }
    
    struct Delegate: DropDelegate {
        @Binding var draggingOver: Bool
        @Binding var urls: [URL]
        @Binding var goal: Int?
        
        let performer = NSHapticFeedbackManager.defaultPerformer
        
        func dropEntered(info: DropInfo) {
            draggingOver = true
            performer.perform(.generic, performanceTime: .now)
        }
        
        func dropExited(info: DropInfo) {
            draggingOver = false
            performer.perform(.generic, performanceTime: .now)
        }

        func performDrop(info: DropInfo) -> Bool {
            // TODO: Should show alert if not .mp3
            let providers = info.itemProviders(for: ["public.file-url"])
            
            goal = providers.count
            for provider in providers {
                provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
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
    
    @Environment(\.dismiss) var dismiss
    
    let systemName: String
    let instruction: String
    let albums: [String]
    let artists: [String]
    
    @State private var albumSelection: Int = 0
    @State var albumCustom: String = ""
    @FocusState private var isAlbumCustomFocused: Bool
    
    @State private var artistSelection: Int = 0
    @State var artistsCustom: String = ""
    @FocusState private var isArtistsCustomFocused: Bool
    
    private var header: some View {
        Group {
            Text(instruction)
                .fontWeight(.bold)
                .lineSpacing(4)
            Divider()
        }.offset(y: 1.2)
    }
    
    private var main: some View {
        Section {
            Picker("**Album**", selection: $albumSelection) {
                ForEach(Array(albums.enumerated()), id: \.offset) { index, title in
                    Text(title).tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .foregroundColor(.secondary)
            .onAppear {
                if albums.isEmpty {
                    albumSelection = -1
                    isAlbumCustomFocused = true
                }
            }
            .onChange(of: albumSelection) { value in
                if value == -1 { isAlbumCustomFocused = true }
            }
            
            TextField("", text: $albumCustom)
                .disabled(albumSelection != -1)
                .focused($isAlbumCustomFocused)
            
            Picker("**Artist(s)**", selection: $artistSelection) {
                ForEach(Array(artists.enumerated()), id: \.offset) { index, artists in
                    Text(artists).tag(index)
                }
                Divider()
                Text("Other…").tag(-1)
            }
            .foregroundColor(.secondary)
            .onAppear {
                if artists.count == 0 {
                    artistSelection = -1
                    isArtistsCustomFocused = true
                }
            }
            .onChange(of: artistSelection) { value in
                if value == -1 { isArtistsCustomFocused = true }
            }
            
            TextField("", text: $artistsCustom)
                .disabled(artistSelection != -1)
                .focused($isArtistsCustomFocused)
            
            Spacer().frame(height: Metrics.lilSpacing2x)
            
            HStack(spacing: Metrics.lilSpacing) {
                Spacer()
                
                Button("Cancel") { dismiss() }
                    .buttonStyle(.borderless)
                    .keyboardShortcut(.escape, modifiers: [])
                
                Button(action: willDismiss) { Text("**Search**") }
                    .buttonStyle(.borderless)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(!isValid)
            }
        }
    }
    
    var body: some View {
        Form {
            header
            
            Spacer()
            
            main
        }
        .modifier(ConfigureSheet(systemName: systemName))
    }
}

extension ConfirmSheet {
    private var unit: LocalUnit { store.localUnit! }
    
    private var isValid: Bool {
        albumSelection  != -1 ||
        artistSelection != -1 ||
        albumSelection  == -1 && albumCustom   != "" ||
        artistSelection == -1 && artistsCustom != ""
    }
    
    private func willDismiss() {
        store.localUnit!.album = albumSelection == -1 ?
            (albumCustom == "" ? nil : albumCustom) :
            albums[albumSelection]
        
        store.localUnit!.artist = artistSelection == -1 ?
            (artistsCustom == "" ? nil : artistsCustom) :
            artists[artistSelection]
        
        store.willSearch()
        
        dismiss()
    }
}
