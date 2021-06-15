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
    
    @State private var isSettingsPresented: Bool = false
    @State private var searchResult: SearchResult?
    
    @FocusState private var focused: Int?
    @State private var chosen: Int?
    
    let pasteboard = NSPasteboard.general
    
    var shelf: some View {
        Rectangle()
            .frame(height: 84)
            .foregroundColor(.clear)
            .background(LinearGradient(
                stops: [Gradient.Stop(color: Color.white.opacity(0), location: 0),
                        Gradient.Stop(color: Color.white.opacity(0.12), location: 0.4),
                        Gradient.Stop(color: Color.white.opacity(0), location: 1)],
                startPoint: .top, endPoint: .bottom))
            .offset(y: 108)
    }
    
    var body: some View {
        if let _ = store.album {
            ZStack(alignment: .top) {
                if searchResult != nil && store.goal == nil && !store.needUpdate { shelf }
                
                VStack(spacing: lilSpacing2x) {
                    Spacer().frame(height: 12)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            Spacer().frame(width: lilSpacing2x+lilIconLength)
                            
                            if title == "" {
                                Text("Music by ")
                                    .fontWeight(.bold)
                                    .textSelection(.disabled)
                            }
                            Text("\(artists)")
                                .fontWeight(.bold)
                                .foregroundColor(.secondary) +
                            Text(album.artists != nil && album.title != nil ? " – " : "") .fontWeight(.bold) +
                            Text("\(title)")
                                .fontWeight(.bold) +
                            Text(title != "" ? "\(yearText)" : "")
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            
                            Spacer().frame(width: lilSpacing2x+lilIconLength)
                        }
                        .textSelection(.enabled)
                    }
                    
                    if searchResult != nil && store.goal == nil && !store.needUpdate {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: lilSpacing) {
                                Spacer().frame(width: lilSpacing+lilIconLength)
                                
                                ForEach(0..<min(6, results.count)) { index in
                                    ZStack {
                                        if let thumb = results[index].coverImage {
                                            AsyncImage(url: URL(string: thumb)!) { image in
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(2)
                                                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                                                    .focusable(true)
                                                    .focused($focused, equals: index)
                                                    .onTapGesture {
                                                        focused = index
                                                        chosen = index
                                                    }
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 80, height: 80)
                                            .frame(height: 100)
                                        }
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            
                                        }) { Text("Pick-It") }
                                        Divider()
                                        Button(action: { openURL(URL(string: "https://discogs.com\(results[index].uri)")!) })
                                            { Text("View on Discogs") }
                                        Button(action: { openURL(URL(string: results[index].coverImage!)!) })
                                            { Text("View Artwork in Broswer") }
                                    }
                                }
                                
                                Spacer().frame(width: lilSpacing+lilIconLength)
                            }
                        }
                        .padding(.vertical, -9.5)
                        .onAppear {
                            focused = 0
                            chosen = 0
                        }
                        
                        HStack(spacing: lilSpacing) {
                            /*
                            ButtonCus(action: { isSettingsPresented = true },
                                      label: "Settings",
                                      systemName: "gear")
                            .sheet(isPresented: $isSettingsPresented, onDismiss: {}) {
                                SettingsSheet(systemName: "gear",
                                              instruction:
                                    "Adjust global settings for picking rather album.")
                            }
                             */
                            ButtonCus(action: {}, label: "Show Only", systemName: "rosette")
                            
                            ButtonCus(action: { openURL(URL(string: chosenUri)!) }, label: "View on Discogs",
                                      systemName: "smallcircle.fill.circle")
                            
                            ButtonCus(action: {}, label: "Pick-It", systemName: "bag")
                        }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: lilSpacing) {
                                    Spacer().frame(width: lilSpacing+lilIconLength)
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Versus")
                                            .fontWeight(.bold)
                                        Text("Format")
                                            .fontWeight(.bold)
                                            .opacity(results[(chosen ?? 0)].format != nil ? 1 : 0.3)
                                        Text("Released")
                                            .fontWeight(.bold)
                                            .opacity(results[(chosen ?? 0)].year != nil ? 1 : 0.3)
                                        
                                        Spacer()  // Keep 2 VStack aligned
                                    }
                                    .foregroundColor(.secondary)
                                    .animation(.default, value: chosen)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(chosenTitle)")
                                            .fontWeight(.bold)
                                        Text("\(chosenFormat)")
                                            .fontWeight(.bold)
                                        Text("\(chosenYear)")
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                    }
                                    .textSelection(.enabled)
                                    
                                    Spacer().frame(width: lilSpacing+lilIconLength)
                                }
                            }
                            .transition(.opacity)
                        
                    }
                    
                    Spacer()
                }
                .frame(width: unitLength, height: unitLength)
                
                if store.page == 2 && store.needUpdate {
                    Spacer()
                        .onAppear {
                            async {
                                searchResult = nil
                                do { try await search() }
                                    catch { print(error) }
                                store.needUpdate = false
                                withAnimation {
                                    store.goal = nil
                                }
                                focused = 0
                                chosen = 0
                            }
                        }
                }
            }
        }
    }
}

extension ChooseView {
    private var album: Album { store.album! }
    private var title: String { album.title ?? "" }
    private var artists: String { album.artists ?? "" }
    private var yearText: String {
        if let year = album.year { return " (\(year))" } else { return "" }
    }
    
    private var results: [SearchResult.Results] {
        searchResult!.results
    }
    
    private var chosenUri: String {
        "https://discogs.com\(results[(chosen ?? 0)].uri)"
    }
    
    private var chosenTitle: String {
        results[(chosen ?? 0)].title
            .replacingOccurrences(of: " - ", with: " – ")
            .replacingOccurrences(of: "*", with: "†")
    }
    private var chosenFormat: String {
        results[(chosen ?? 0)].format?.uniqued().joined(separator: " / ") ?? "*"
    }
    private var chosenYear: String {
        results[(chosen ?? 0)].year ?? ""
    }
    
    enum SearchError: Error {
        case urlNotSucceed
    }
    
    private func search() async throws {
        let (data, response) = try await URLSession.shared.data(from: store.searchUrl!)
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else { throw SearchError.urlNotSucceed }
        
        do {
            let result = try JSONDecoder().decode(SearchResult.self, from: data)
            withAnimation {
                searchResult = result
            }
        }
        catch { throw error }
    }
}

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let systemName: String
    let instruction: String
    
    var body: some View {
        Form {
            Group {
                Text(instruction)
                    .lineSpacing(4)
                Divider()
            }.offset(y: 1.2)
            
            Spacer()
            
            TextField("**Debugging**", text: .constant(""))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Spacer().frame(height: lilSpacing2x)
            
            HStack {
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("**Apply**")
                }
                .controlProminence(.increased)
            }
        }.modifier(ConfigureSheet(systemName: systemName))
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
