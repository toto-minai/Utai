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
    @FocusState private var chosen: Int?
    
    var titleText: String { store.album!.title ?? "" }
    var artistsText: String { store.album!.artists ?? "" }
    var yearText: String {
        if let year = store.album!.year {
            return " (\(year)"
        } else {
            if store.album!.yearCandidates.count != 0
                { return " (\(store.album!.yearCandidates.first!))" }
            else { return "" }
        }
    }
    
    var body: some View {
        if store.page == 2 {
            ZStack(alignment: .top) {
                if let _ = store.searchResult {
                    Rectangle()
                        .frame(height: 84)
                        .foregroundColor(.clear)
                        .background(LinearGradient(stops: [Gradient.Stop(color: Color.white.opacity(0), location: 0),
                                                           Gradient.Stop(color: Color.white.opacity(0.12), location: 0.4),
                                                           Gradient.Stop(color: Color.white.opacity(0), location: 1)],
                                                   startPoint: .top, endPoint: .bottom))
                        .offset(y: 108)
                }
                
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
                    
                    if let r = store.searchResult {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Spacer().frame(width: 8+12)
                                
                                ForEach(0..<min(10, r.results.count)) { index in
                                    if let thumb = r.results[index].coverImage {
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
                        .padding(.vertical, -10)
                        .onAppear { chosen = 0 }
                        
                        HStack(spacing: 8) {
                            Button(action: { isSettingsPresented = true }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "gear")
                                        .font(.system(size: 12))
                                        .offset(y: -1.2)
                                    Text("**Settings**")
                                }
                            }
                            .buttonStyle(.borderless)
                            .focusable(false)
                            .sheet(isPresented: $isSettingsPresented, onDismiss: {}) {
                                SettingsSheet()
                            }
                            
                            Button(action: {
                                let discogs = "https://discogs.com\(r.results[(chosen ?? 0)].uri)"
                                openURL(URL(string: discogs)!)
                            }) {
                                HStack(spacing: 2) {
                                    Image(systemName: "smallcircle.fill.circle.fill")
                                        .font(.system(size: 12))
                                        .offset(y: -1.2)
                                    Text("**View on Discogs**")
                                }
                            }
                            .buttonStyle(.borderless)
                            .focusable(false)
                            
                            Button(action: {}) {
                                HStack(spacing: 2) {
                                    Image(systemName: "bag")
                                        .font(.system(size: 12))
                                        .offset(y: -1.2)
                                    Text("**Pick-It**")
                                }
                            }
                            .buttonStyle(.borderless)
                            .focusable(false)
                        }
                        
//                        if let chosen = chosen {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Spacer().frame(width: 2*8+12)
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("**Versus**")
                                        Text("**Format**")
                                            .opacity(r.results[(chosen ?? 0)].format != nil ? 1 : 0.3)
                                        Text("**Released**")
                                            .opacity(r.results[(chosen ?? 0)].year != nil ? 1 : 0.3)
                                        
                                        Spacer()  // Keep 2 VStack aligned
                                    }
                                    .foregroundColor(.secondary)
                                    .animation(.default, value: chosen)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("**\(r.results[(chosen ?? 0)].title.replacingOccurrences(of: " - ", with: " – ").replacingOccurrences(of: "*", with: "†"))**")
                                        Text("**\(r.results[(chosen ?? 0)].format?.uniqued().joined(separator: " / ") ?? "*")**")
                                        Text("**\(r.results[(chosen ?? 0)].year ?? "")**")
                                        
                                        Spacer()
                                    }
                                    
                                    Spacer().frame(width: 2*8+12)
                                }
                            }
//                        }
                        
                    }
                    
                    Spacer()
                }
                .frame(width: unitLength, height: unitLength)
            }
            .onAppear {
                if store.searchResult == nil {
                    store.searchOnDiscogs()
                }
            }
        }
    }
}

struct SettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "gear")
                .font(.system(size: 12))
                .padding(8)
            
            Form {
                Group {
                    Text("Adjust global settings for picking rather album.")
                    Divider()
                }.offset(y: 1.2)
                
                Spacer()
                
                TextField("**Debugging**", text: .constant(""))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Spacer().frame(height: 16)
                
                HStack {
                    Spacer()
                    
//                    Button(action: { dismiss() }) {
//                        Text("Cancel")
//                    }
//                    .buttonStyle(.borderless)
                    
                    Button(action: { dismiss() }) {
                        Text("**Apply**")
                    }
                    .controlProminence(.increased)
                }
            }
            .padding([.leading], 16)
            .padding([.trailing, .bottom, .top], 8)
            .frame(width: 256, height: 256)
        }
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
