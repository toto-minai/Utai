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
                    ForEach(results.indices) { index in
                        Artwork80x80(chosen: $chosen, response: $response, index: index)
                    }
                }
                .padding(.horizontal, lilSpacing2x+lilIconLength)
                // Cancel shadow-clipping: 2. Left spacing to shrink
                .frame(height: 120)
            }
            // Cancel shadow-clipping: 3. Negative padding
            .padding(.vertical, -20)
        }
    }
    
    var footer: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Menu {
                    Menu("Show") {
                        Text("Masters Only")
                        Text("Releases Only")
                        Divider()
                        Text("Both")
                    }
                    Menu("Filter") {
                        Text("Label")
                        Text("Country / Region")
                        Text("Year")
                    }
                    Divider()
                    Menu("Sort By") {
                        Text("Default")
                        Divider()
                        Text("Masters, Releases")
                        Text("Country / Region")
                        Text("Year")
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
                                            .opacity(results[chosen].formats != nil ? 1 : 0.3)
                                        Text("Labal")
                                            .fontWeight(.medium)
                                        Text(" ")
                                        
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
                                            openURL(URL(string: "https://discogs.com\(results[chosen].uri)")!)
                                        }
                                        .buttonStyle(.borderless)
                                        .foregroundColor(.secondary)
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
        void.onAppear { if chosen == nil { chosen = 0 } }
    }
    
    var refreshWhenNeededUpdate: some View {
        void.onAppear {
            async {
                response = nil
                
                do { try await search() }
                catch { print(error) }
                
                store.needUpdate = false
                
                chosen = 0
                
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
    
    private var chosenInfoRaw: String {
        if let chosen = chosen {
            return results[chosen].title
                .replacingOccurrences(of: " - ", with: " – ")
                .replacingOccurrences(of: "*", with: "†")
        } else { return "" }
    }
    
    private var chosenYearCR: String {
        if let chosen = chosen {
            var processed = [results[chosen].year,
                             results[chosen].country]
            processed.removeAll { $0 == nil }
            
            return processed.map { $0!.replacingOccurrences(of: " & ", with: ", ") }.joined(separator: ", ")
        } else { return " " }
    }
    
    private var chosenFormatStyled: String {
        if let chosen = chosen,
           let formats = results[chosen].formats,
           let first = formats.first {
            let filtered = first.descriptions ?? []
            
//            let filtered = first.descriptions?.filter {
//                $0 != "LP" && $0 != "Album"
//            } ?? []
            
            return first.name + (filtered.isEmpty ?
                " " : " (\(filtered.joined(separator: ", ")))")
        } else { return " " }
    }
    
    private var chosenLabelStyled: String {
        if let chosen = chosen,
           let label = results[chosen].label,
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
    @Binding var response: SearchResponse?
    
    let index: Int
    
    var body: some View {
        ZStack {
            if let thumb = result.coverImage {
                AsyncImage(url: URL(string: thumb)!) { image in
                    ZStack {
                        image.resizable().scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(36)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.accentColor
                                    .opacity(
                                        (chosen != nil && chosen! == index) ?
                                        1 : 0.001), lineWidth: 1.5))
                            .blur(radius: 3.6)
                            .frame(width: 80, height: 120).clipped()
                            .offset(y: 2.4)
                        
                        image.resizable().scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.54),
                                    radius: 3.6, x: 0, y: 2.4)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.accentColor
                                    .opacity(
                                        (chosen != nil && chosen! == index) ?
                                        1 : 0.001), lineWidth: 1.5))
                            .onTapGesture {
                                if chosen == index {
                                    pick(from: index)
                                } else { withAnimation(.easeOut) { chosen = index } }
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
            Button(action: { pick(from: index) }) { Text("Pick Up") }
            Divider()
            Button(action: { openURL(URL(string: "https://discogs.com\(result.uri)")!) })
            { Text("View on Discogs") }
            Button(action: { openURL(URL(string: result.coverImage!)!) })
            { Text("Open Artwork in Broswer") }
        }
    }
}

extension Artwork80x80 {
    private var results: [SearchResponse.Result] {
        response!.results
    }
    
    private var result: SearchResponse.Result { results[index] }
    
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
