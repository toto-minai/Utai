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
    
    @FocusState private var chosen: Int?
    
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
                if let _ = searchResult { shelf }
                
                VStack(spacing: 16) {
                    Spacer().frame(height: 12)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 2*8+12)
                            
                            Text("**\(artistsText)**")
                                .foregroundColor(.secondary)
                            if store.album!.artists != nil && store.album!.title != nil {
                                Text(" – ")
                                    .fontWeight(.bold)
                            }
                            Text("**\(titleText)**")
                            Text("**\(yearText)**")
                                .foregroundColor(.secondary)
                            
                            Spacer().frame(width: 2*8+12)
                        }
                    }
                    
                    if let _ = searchResult {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Spacer().frame(width: 8+12)
                                
                                ForEach(0..<min(6, results.count)) { index in
                                    if let thumb = results[index].coverImage {
                                        AsyncImage(url: URL(string: thumb)!) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .cornerRadius(4)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 80, height: 80)
                                        .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
                                        .frame(height: 100)
                                        .focusable(true)
                                        .focused($chosen, equals: index)
                                        .onTapGesture {
                                            chosen = index
                                        }
                                    }
                                }
                                
                                Spacer().frame(width: 8+12)
                            }
                        }
                        .padding(.vertical, -9.5)
                        .onAppear { chosen = 0 }
                        
                        HStack(spacing: 8) {
                            ButtonCus(action: { isSettingsPresented = true },
                                      label: "Settings",
                                      systemName: "gear")
                            .sheet(isPresented: $isSettingsPresented, onDismiss: {}) {
                                SettingsSheet(systemName: "gear",
                                              instruction:
                                    "Adjust global settings for picking rather album.")
                            }
                            
                            ButtonCus(action: {
                                let discogs = "https://discogs.com\(results[(chosen ?? 0)].uri)"
                                openURL(URL(string: discogs)!)
                            }, label: "View on Discogs",
                                      systemName: "smallcircle.fill.circle.fill")
                            
                            ButtonCus(action: {}, label: "Pick-It", systemName: "bag")
                        }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Spacer().frame(width: 2*8+12)
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("**Versus**")
                                        Text("**Format**")
                                            .opacity(results[(chosen ?? 0)].format != nil ? 1 : 0.3)
                                        Text("**Released**")
                                            .opacity(results[(chosen ?? 0)].year != nil ? 1 : 0.3)
                                        
                                        Spacer()  // Keep 2 VStack aligned
                                    }
                                    .foregroundColor(.secondary)
                                    .animation(.default, value: chosen)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("**\(results[(chosen ?? 0)].title.replacingOccurrences(of: " - ", with: " – ").replacingOccurrences(of: "*", with: "†"))**")
                                        Text("**\(results[(chosen ?? 0)].format?.uniqued().joined(separator: " / ") ?? "*")**")
                                        Text("**\(results[(chosen ?? 0)].year ?? "")**")
                                        
                                        Spacer()
                                    }
                                    
                                    Spacer().frame(width: 2*8+12)
                                }
                            }
                        
                    }
                    
                    Spacer()
                }
                .frame(width: unitLength, height: unitLength)
                
                if store.page == 2 {
                    Spacer()
                        .onAppear {
                            if store.needUpdate {
                                query()
                                
                            }
                        }
                }
            }
        }
    }
}

extension ChooseView {
    private var titleText: String { store.album!.title ?? "" }
    private var artistsText: String { store.album!.artists ?? "" }
    private var yearText: String {
        if let year = store.album!.year {
            return " (\(year)"
        } else {
            if store.album!.yearCandidates.count != 0
                { return " (\(store.album!.yearCandidates.first!))" }
            else { return "" }
        }
    }
    
    private var results: [SearchResult.Results] {
        searchResult!.results
    }
    
    private func query() {
        URLSession.shared.dataTask(with: store.searchUrl!) { data, _, _ in
            do {
                if let data = data {
                    let result = try JSONDecoder().decode(SearchResult.self, from: data)
                    
                    searchResult = result
                }
            } catch { print(error) }
        }.resume()
        
        store.needUpdate = false
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
                Divider()
            }.offset(y: 1.2)
            
            Spacer()
            
            TextField("**Debugging**", text: .constant(""))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Spacer().frame(height: 16)
            
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
