//
//  MatchPanel.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/13.
//

import SwiftUI

struct MatchPanel: View {
    @EnvironmentObject var store: Store
    @State private var scrolled: CGFloat = 0
    
    var body: some View {
        ZStack {
            GeometryReader { outter in
                ScrollView(.vertical) {
                    ZStack(alignment: .top) {
                        GeometryReader { inner in
                            Text("")
                                .preference(key: ScrolledPreferenceKey.self,
                                            value: [delta(outter: outter, inner: inner)])
                        }
                        
                        VStack(alignment: .leading, spacing: lilSpacing2x) {
                            HStack(spacing: 0) {
                                Text(store.page < 3 ? "Tracklist" : "Mismatched")
                                    .fontWeight(.bold)
                                
                                Text(" (\(tracks.count) track\(tracks.count == 1 ? "" : "s"))")
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                                
                            VStack(spacing: 8) {
                                ForEach(tracksSortedByNo) { track in
                                    HStack(spacing: 0) {
                                        GroupBox {
                                            HStack(spacing: 8) {
                                                Text("\(track.trackNoText)")
                                                    .fontWeight(.bold)
                                                    .monospacedDigit()
                                                    .foregroundColor(.secondary)
                                                    .frame(width: 16)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("**\(track.title ?? track.filename.withoutExtension)**")
                                                        .lineSpacing(4)
                                                        .foregroundColor(.primary)
                                                        .textSelection(.enabled)
                                                        
                                                    if album.artists == nil ||
                                                        track.artist != nil && track.artist != album.artists! {
                                                        Text("**\(track.artist!)**")
                                                            .lineSpacing(4)
                                                            .foregroundColor(.secondary)
                                                            .textSelection(.enabled)
                                                    }
                                                }
                                                .padding(8)
                                                .background(TranslucentBackground())
                                                .cornerRadius(4)
                                                
                                                Text("\(track.lengthText)")
                                                    .fontWeight(.bold)
                                                    .monospacedDigit()
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                            
                                        Spacer()
                                            .frame(width: lilSpacing2x+lilIconLength)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.leading, lilSpacing2x+lilIconLength)
                .padding(.top, lilSpacing2x+lilIconLength)
                .onPreferenceChange(ScrolledPreferenceKey.self) { value in
                    scrolled = value[0]
                }
            }
            
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(TranslucentBackground())
                        .frame(height: lilSpacing2x+lilIconLength-0.5)
                    
                }
                    
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.secondary.opacity(0.4))
                
                Spacer()
            }
            .opacity(scrolled > 0 ? 1 : 0)
            
            VStack {
                HStack {
                    Spacer()
                    
                    ButtonMini(systemName: "sidebar.squares.right", helpText: "Hide Match")
                        .onTapGesture {
                            store.showMatchPanel = false
                        }
                }
                .padding(8)
                
                Spacer()
            }
        }
        .frame(width: unitLength)
    }
}

extension String {
    var withoutExtension: String {
        self.split(separator: ".").dropLast().joined(separator: ".")
    }
}

extension MatchPanel {
    var album: Album {
        store.album!
    }
    
    var tracks: [Album.Track] {
        store.album!.tracks
    }
    
    var tracksSortedByNo: [Album.Track] {
        store.album!.tracks.sorted {
            ($0.trackNo ?? 0) < ($1.trackNo ?? 0)
        }
    }
    
    struct ScrolledPreferenceKey: PreferenceKey {
        static var defaultValue: [CGFloat] = [0]

        static func reduce(value: inout [CGFloat],
                           nextValue: () -> [CGFloat]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    private func delta(outter: GeometryProxy, inner: GeometryProxy) -> CGFloat {
        return outter.frame(in: .global).minY - inner.frame(in: .global).minY
    }
}
