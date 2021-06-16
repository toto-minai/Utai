//
//  ChooseView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import SwiftUI

struct ChooseView: View {
    @EnvironmentObject var store: Store
    
    @State private var pending: Bool = false  // i.e. response != nil
    @State private var response: SearchResponse?
    
    @State private var chosen: Int?
    
    var body: some View {
        if store.album != nil {
            ZStack(alignment: .top) {
                VStack(spacing: lilSpacing2x) {
                    header
                    
                    if !pending &&
                        store.goal == nil && // Are they required?
                        !store.needUpdate {
                        artworks
                        
                        if let chosen = chosen {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: lilSpacing) {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Versus")
                                            .fontWeight(.medium)
                                        Text("Format")
                                            .fontWeight(.medium)
                                            .opacity(results[chosen].formats != nil ? 1 : 0.3)
                                        Text("Released")
                                            .fontWeight(.medium)
                                            .opacity(results[chosen].year != nil ? 1 : 0.3)
                                        
                                        Spacer()  // Keep 2 VStack aligned
                                    }
                                    .foregroundColor(.secondary)
                                    .animation(.default, value: chosen)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(chosenInfoRaw)")
                                            .fontWeight(.medium)
                                            .animation(nil)
                                        Text("\(chosenFormatStyled)")
                                            .fontWeight(.medium)
                                            .animation(nil)
                                        Text("\(chosenYearCR)")
                                            .fontWeight(.medium)
                                            .animation(nil)
                                        
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
                
                void.onAppear {
                    chosen = nil
                }
                
                if store.page == 2 && store.needUpdate {
                    void.onAppear {
                        async {
                            pending = true
                            
                            do { try await search() }
                            catch { print(error) }
                            
                            store.needUpdate = false
                            
                            withAnimation {
                                store.goal = nil
                            }
                        }
                    }
                }
            }
            .frame(width: unitLength, height: unitLength)
            // Deselect artwork
            .onTapGesture { withAnimation(.easeOut) { chosen = nil } }
        }
    }
}

extension ChooseView {
    private var album: Album { store.album! }
    private var titleRaw: String { album.title ?? "" }
    private var artistsRaw: String { album.artists ?? "" }
    
    private var header: some View {
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
    
    private var chosenFormatStyled: String {
        if let chosen = chosen,
           let formats = results[chosen].formats,
           let first = formats.first {
            let filtered = first.descriptions?.filter {
                $0 != "LP" && $0 != "Album"
            } ?? []
            
            return first.name + (filtered.isEmpty ?
                " " : " (\(filtered.joined(separator: ", ")))")
        } else { return " " }
    }
    
    private var chosenYearCR: String {
        if let chosen = chosen {
            var processed = [results[chosen].year,
                             results[chosen].country]
            processed.removeAll { $0 == nil }
            
            return processed.map { $0! }.joined(separator: ", ")
        } else { return " " }
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
    
    enum SearchError: Error { case badURL }
    
    private func search() async throws {
        let (data, code) = try await URLSession.shared.data(from: store.searchURL!)
        guard (code as? HTTPURLResponse)?.statusCode == 200
        else { throw SearchError.badURL }
        
        do {
            response = try JSONDecoder().decode(SearchResponse.self, from: data)
            withAnimation { pending = false }
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
                            .cornerRadius(36).blur(radius: 3.6)
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
                                            1 : 0.001), lineWidth: 2.7))
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
            Button(action: { pick(from: index) }) { Text("Pick It") }
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
