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
            searchOnDiscogs(title: store.album!.title, artists: store.album!.artists)
        }
    }
    
    func searchOnDiscogs(title: String?, artists: String?) {
        var componets = URLComponents()
        componets.scheme = "https"
        componets.host = "api.discogs.com"
        componets.path = "/database/search"
        componets.queryItems = [
            URLQueryItem(name: "key", value: discogs_key),
            URLQueryItem(name: "secret", value: discogs_secret)
        ]
        
        if let title = title {
            componets.queryItems!.append(URLQueryItem(name: "q", value: title))
        }
        if let artists = artists {
            componets.queryItems!.append(URLQueryItem(name: "artist", value: artists))
        }
        
        URLSession.shared.dataTask(with: componets.url!) { data, _, _ in
            do {
                if let data = data {
                    store.searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                    print(store.searchResult)
                }
            } catch { print(error) }
        }.resume()
    }
    
    var body: some View {
        return VStack(spacing: 0) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .foregroundColor(Color.black.opacity(0.2))
                        .frame(width: 114, height: 114)
                    
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
                }
            }
            .offset(y: 66)
            
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
//    @Binding var isConfirmPresented: Bool
    
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
        
//        isConfirmPresented = false
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
