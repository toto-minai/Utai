//
//  ChooseView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import SwiftUI

struct ChooseView: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    @State private var response: SearchResponse?
    
    @State private var chosen: Int?
    
    var header: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                if album.title == nil {
                    Text("Music by ")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                        .textSelection(.disabled)
                }
                Text("\(artistsRaw)")
                    .fontWeight(.medium) +
                Text(album.artists != nil &&
                     album.title != nil ? " – " : "")
                    .fontWeight(.medium) +
                Text("\(titleRaw)")
                    .fontWeight(.medium)
            }
            .textSelection(.enabled)
            .padding(.horizontal, lilSpacing2x+lilIconLength)
        }
    }
    
    var artworks: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: lilSpacing) {
                    ForEach(resultsProcessed, id: \.id) { result in
                        Artwork80x80(chosen: $chosen, result: result)
                    }
                }
                .padding(.horizontal, lilSpacing2x+lilIconLength)
                // Cancel shadow-clipping: 2. Left spacing to shrink
                .frame(height: 120)
            }
            // Cancel shadow-clipping: 3. Negative padding
            .padding(.vertical, -20)
            .onChange(of: showMode) { newValue in
                proxy.scrollTo(chosen, anchor: .top)
            }
            .onChange(of: sortMode) { newValue in
                proxy.scrollTo(chosen, anchor: .top)
            }
        }
    }
    
    @State private var showMode: ShowMode = .both
    private var showModeMask: Binding<ShowMode> {
        Binding { showMode } set: {
            showMode = $0
            
            if let first = resultsProcessed.first {
                chosen = first.id
            } else {
                chosen = nil
            }
        }
    }
    
    @State private var filterMode: FilterMode = .none
    
    @State private var sortMode: SortMode = .none
    
    var footer: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Menu {
                    Picker("Show", selection: showModeMask) {
                        Text("Masters Only").tag(ShowMode.master)
                        Text("Releases Only").tag(ShowMode.release)
                        Divider()
                        Text("Both").tag(ShowMode.both)
                    }
                    
                    Menu("Filter") {
                        Text("Label")
                        Text("Country / Region")
                        Text("Year")
                    }
                    Divider()
                    Picker("Sort By", selection: $sortMode) {
                        Text("Discogs").tag(SortMode.none)
                        Divider()
                        Text("Master, Release").tag(SortMode.MR).disabled(showMode != .both)
                        Text("Country / Region").tag(SortMode.CR)
                        Text("Year").tag(SortMode.year)
                    }
                } label: {
                    ButtonMini(alwaysHover: true, systemName: "ellipsis.circle", helpText: "Options")
                        .padding(lilSpacing)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuIndicator(.hidden)
                .frame(width: lilSpacing2x+lilIconLength,
                       height: lilSpacing2x+lilIconLength)
                .offset(x: 3, y: -0.5)
            }
        }
    }
    
    var body: some View {
        if store.album != nil {
            ZStack(alignment: .top) {
                VStack(spacing: lilSpacing2x) {
                    header
                    
                    if response != nil &&  // `response == nil` means pending
                        store.goal == nil && // Are they required?
                        !store.needUpdate {
                        artworks
                        
                        if let chosen = chosen {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: lilSpacing) {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Versus")
                                            .fontWeight(.medium)
                                        Text("Released")
                                            .fontWeight(.medium)
                                            .opacity(chosenYearCR != " " ? 1 : 0.3)
                                        Text("Format")
                                            .fontWeight(.medium)
                                            .opacity(chosenResult.formats != nil ? 1 : 0.3)
                                        Text("Labal")
                                            .fontWeight(.medium)
                                        
                                        Spacer()  // Keep 2 VStack aligned
                                    }
                                    .foregroundColor(.secondary)
                                    .animation(.default, value: chosen)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(chosenInfoRaw)")
                                            .fontWeight(.medium)
                                            .animation(nil)
                                        Text("\(chosenYearCR)")
                                            .fontWeight(.medium)
                                            .animation(nil)
                                        Text("\(chosenFormatStyled)")
                                            .fontWeight(.medium)
                                            .animation(nil)
                                        Text("\(chosenLabelStyled)")
                                            .fontWeight(.medium)
                                            .animation(nil)
                                        Button("**View on Discogs**") {
                                            openURL(URL(string: "https://discogs.com\(chosenResult.uri)")!)
                                        }
                                        .buttonStyle(.borderless)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 2)
                                        .textSelection(.disabled)
                                        
                                        Spacer()
                                    }
                                    .textSelection(.enabled)
                                }
                                .padding(.horizontal, lilSpacing2x+lilIconLength)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, lilSpacing2x+lilIconLength)
                
                footer
                
                if store.page == 2 {
                    refreshWhenTurnToThisPage
                    
                    if store.needUpdate  { refreshWhenNeededUpdate }
                }
            }
            .frame(width: unitLength, height: unitLength)
        }
    }
    
    var refreshWhenTurnToThisPage: some View {
        void.onAppear {
            if chosen == nil && response != nil {
                if let first = resultsProcessed.first {
                    chosen = first.id
                }
            }
        }
    }
    
    var refreshWhenNeededUpdate: some View {
        void.onAppear {
            async {
                response = nil
                
                do { try await search() }
                catch { print(error) }
                
                store.needUpdate = false
                
                if let first = resultsProcessed.first {
                    chosen = first.id
                } else {
                    chosen = nil
                }
                
                withAnimation {
                    store.goal = nil
                }
            }
        }
    }
}

extension ChooseView {
    private var album: Album { store.album! }
    private var titleRaw: String { album.title ?? "" }
    private var artistsRaw: String { album.artists ?? "" }
    
    private var results: [SearchResponse.Result] {
        response!.results
    }
    
    private var resultsProcessed: [SearchResponse.Result] {
        var processed = results
        
        switch showMode {
        case .master:
            processed = processed.filter {
                $0.type == "master"
            }
        case .release:
            processed = processed.filter {
                $0.type == "release"
            }
        default: break
        }
        
        switch sortMode {
        case .MR:
            processed = processed.sorted {
                $1.type == "release" && $0.type == "master"
            }
        // case .CR:
        case .year:
            processed = processed.sorted { former, latter in
                let x = former.year != nil ? Int(former.year!) ?? Int.max : Int.max
                let y = latter.year != nil ? Int(latter.year!) ?? Int.max : Int.max
                
                return x < y
            }
        default: break
        }
        
        return processed
    }
    
    private var chosenResult: SearchResponse.Result { resultsProcessed.first { $0.id == chosen }! }
    
    private var chosenInfoRaw: String {
        if chosen != nil {
            return chosenResult.title
                .replacingOccurrences(of: " - ", with: " – ")
                .replacingOccurrences(of: "*", with: "†")
        } else { return "" }
    }
    
    private var chosenYearCR: String {
        if chosen != nil {
            var processed = [chosenResult.year,
                             chosenResult.country]
            processed.removeAll { $0 == nil }
            
            return processed.map { $0!.replacingOccurrences(of: " & ", with: ", ") }.joined(separator: ", ")
        } else { return " " }
    }
    
    private var chosenFormatStyled: String {
        if let _ = chosen,
           let formats = chosenResult.formats,
           let first = formats.first {
            let filtered = first.descriptions ?? []
            
            return first.name + (filtered.isEmpty ?
                " " : " (\(filtered.joined(separator: ", ")))")
        } else { return " " }
    }
    
    private var chosenLabelStyled: String {
        if let _ = chosen,
           let label = chosenResult.label,
           let first = label.first {
            return first
        } else { return " " }
    }
    
    enum SearchError: Error { case badURL }
    
    private func search() async throws {
        let (data, code) = try await URLSession.shared.data(from: store.searchURL!)
        guard (code as? HTTPURLResponse)?.statusCode == 200
        else { throw SearchError.badURL }
        
        do {
            let response = try JSONDecoder().decode(SearchResponse.self, from: data)
            withAnimation { self.response = response }
        } catch { throw error }
    }
    
    private func pick(from index: Int) {
        var componets = URLComponents(url: results[index].resourceURL, resolvingAgainstBaseURL: false)!
        componets.queryItems = [
            URLQueryItem(name: "key", value: discogs_key),
            URLQueryItem(name: "secret", value: discogs_secret)
        ]
        
        store.matchUrl = componets.url
        
        store.showMatchPanel = true
        store.page = 3
        store.needMatch = true
    }
}

struct Artwork80x80: View {
    @EnvironmentObject var store: Store
    
    @Environment(\.openURL) var openURL
    
    @Binding var chosen: Int?
    
    let result: SearchResponse.Result
    
    var body: some View {
        ZStack {
            if let thumb = result.coverImage {
                AsyncImage(url: URL(string: thumb)!) { image in
                    ZStack {
                        image.resizable().scaledToFill()
                            .frame(width: 80, height: 80)
                            .frame(height: 40, alignment: .bottom)
                            .cornerRadius(36)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.accentColor
                                    .opacity(
                                        (chosen != nil && chosen! == result.id) ?
                                        1 : 0.001), lineWidth: 1.5))
                            .blur(radius: 3.6)
                            .frame(width: 76, height: 120).clipped()
                            .offset(y: 2.4+20)
                        
                        image.resizable().scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.54),
                                    radius: 3.6, x: 0, y: 2.4)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.accentColor
                                    .opacity(
                                        (chosen != nil && chosen! == result.id) ?
                                        1 : 0.001), lineWidth: 1.5))
                            .onTapGesture {
                                if chosen == result.id {
                                    pick(from: result.id)
                                } else { withAnimation(.easeOut) { chosen = result.id } }
                            }
                    }
                    .id(result.id)
                } placeholder: { ProgressView() }
                .frame(width: 80, height: 80)
            } else { Color.red.frame(width: 80, height: 80) }
        }
        // Cancel shadow-clipping: 1. Positive padding
        .padding(.vertical, 20)
        .contextMenu {
            Button(action: { pick(from: result.id) }) { Text("Pick Up") }
            Divider()
            Button(action: { openURL(URL(string: "https://discogs.com\(result.uri)")!) })
            { Text("View on Discogs") }
            Button(action: { openURL(URL(string: result.coverImage!)!) })
            { Text("Open Artwork in Broswer") }
        }
    }
}

extension Artwork80x80 {
    private func pick(from index: Int) {
        var componets = URLComponents(url: result.resourceURL,
                                      resolvingAgainstBaseURL: false)!
        componets.queryItems = [
            URLQueryItem(name: "key", value: discogs_key),
            URLQueryItem(name: "secret", value: discogs_secret)
        ]
        
        store.matchUrl = componets.url
        
        store.showMatchPanel = true
        store.page = 3
        store.needMatch = true
    }
}
