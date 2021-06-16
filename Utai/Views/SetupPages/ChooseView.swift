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
    
    enum Showing {
        case master, release, both
    }
    
    @State private var showing: Showing = .both
    
    let pasteboard = NSPasteboard.general
    
    var shelf: some View {
        Rectangle()
            .fill(LinearGradient(
                stops: [Gradient.Stop(color: Color.primary.opacity(0), location: 0),
                        Gradient.Stop(color: Color.primary.opacity(0.2), location: 0.4),
                        Gradient.Stop(color: Color.primary.opacity(0), location: 1)],
                startPoint: .top, endPoint: .bottom))
            .frame(width: 2*unitLength)
            .frame(width: unitLength, height: 84, alignment: .leading)
            .clipped()
            .blur(radius: 10)
            .offset(x: lilIconLength, y: 98)
            
    }
    
    var body: some View {
        if let _ = store.album {
            ZStack(alignment: .top) {
//                if searchResult != nil && store.goal == nil && !store.needUpdate { shelf }
                
                VStack(spacing: lilSpacing2x) {
                    Spacer().frame(height: 12)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            Spacer().frame(width: lilSpacing2x+lilIconLength)
                            
                            if title == "" {
                                Text("Music by ")
                                    .fontWeight(.medium)
                                    .textSelection(.disabled)
                            }
                            Text("\(artists)")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary) +
                            Text(album.artists != nil && album.title != nil ? " – " : "") .fontWeight(.medium) +
                            Text("\(title)")
                                .fontWeight(.medium) +
                            Text(title != "" ? "\(yearText)" : "")
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Spacer().frame(width: lilSpacing2x+lilIconLength)
                        }
                        .textSelection(.enabled)
                    }
                    
                    if searchResult != nil && store.goal == nil && !store.needUpdate {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: lilSpacing) {
                                Spacer().frame(width: lilSpacing+lilIconLength)
                                
                                ForEach(Array(resultsClipped.enumerated()), id: \.offset) { index, element in
                                    ZStack {
                                        if let thumb = results[index].coverImage {
                                            AsyncImage(url: URL(string: thumb)!) { image in
                                                ZStack {
                                                    ZStack {
                                                        image.resizable()
                                                            .scaledToFill()
                                                            .frame(width: 80, height: 80)
                                                        
//                                                        Color.black.opacity(0.2)
                                                    }
                                                        .scaleEffect(0.9)
                                                        .cornerRadius(30)
                                                        .blur(radius: 3.6)
//                                                        .blendMode(.darken)
                                                        .offset(y: 5.4)
                                                    
                                                    image.resizable()
                                                        .scaledToFill()
                                                        .frame(width: 80, height: 80)
                                                        .cornerRadius(4)
                                                        .shadow(color: Color.black.opacity(0.54), radius: 3.6, x: 0, y: 3)
                                                        .focusable(true)
                                                        .focused($focused, equals: index)
                                                        .onTapGesture {
                                                            if focused == index {
                                                                pick(from: index)
                                                            } else {
                                                                focused = index
                                                                chosen = index
                                                            }
                                                        }
                                                }
                                                    
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 80, height: 80)
                                            .frame(height: 100)
                                        }
                                    }
                                    .contextMenu {
                                        Button(action: { pick(from: index) }) { Text("Pick-It") }
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
                            Menu {
                                Picker("Show", selection: $showing, content: {
                                    Text("Masters Only")
                                        .tag(Showing.master)
                                    Text("Releases Only")
                                        .tag(Showing.release)
                                    Divider()
                                    Text("Both")
                                        .tag(Showing.both)
                                })
                                Divider()
                                Picker("Sort by", selection: $showing, content: {
                                    Text("Discogs")
                                        .tag(Showing.master)
                                    Text("Year")
                                        .tag(Showing.release)
                                    Text("Country / Region")
                                        .tag(Showing.both)
                                })
                            } label: {
                                Text("Options")
                                    .font(.custom("Yanone Kaffeesatz", size: 16))
                                    .fontWeight(.medium)
                            }
                            .menuStyle(BorderlessButtonMenuStyle())
                            .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                            .frame(width: 45, alignment: .leading)
                            .padding(.trailing, -2)
                            
                            ButtonCus(action: { openURL(URL(string: chosenUri)!) }, label: "View on Discogs",
                                      systemName: "smallcircle.fill.circle")
                            
                            ButtonCus(action: { pick(from: chosen ?? 0) }, label: "Pick-It", systemName: "bag")
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: lilSpacing) {
                                Spacer().frame(width: lilSpacing+lilIconLength)
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Versus")
                                        .fontWeight(.medium)
                                    Text("Format")
                                        .fontWeight(.medium)
                                        .opacity(results[(chosen ?? 0)].format != nil ? 1 : 0.3)
                                    Text("Released")
                                        .fontWeight(.medium)
                                        .opacity(results[(chosen ?? 0)].year != nil ? 1 : 0.3)
                                    
                                    Spacer()  // Keep 2 VStack aligned
                                }
                                .foregroundColor(.secondary)
                                .animation(.default, value: chosen)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(chosenTitle)")
                                        .fontWeight(.medium)
                                    Text("\(chosenFormat)")
                                        .fontWeight(.medium)
                                    Text("\(chosenYear)")
                                        .fontWeight(.medium)
                                    
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
    
    private var results: [SearchResult.Result] {
        searchResult!.results
    }
    
    private var resultsClipped: [SearchResult.Result] {
        Array(results.prefix(6))
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
