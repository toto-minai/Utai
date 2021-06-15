//
//  MatchPanel.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/13.
//

import SwiftUI

struct MatchPanel: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        ZStack {
            
            
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: lilSpacing2x) {
                    Spacer().frame(height: lilIconLength)
                    
                    HStack(spacing: 0) {
                        Text(store.page < 3 ? "Tracklist" : "Mismatched")
                            .fontWeight(.bold)
                        
                        Text(" (\(tracks.count) track\(tracks.count == 1 ? "" : "s"))")
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
                                    
                                    Text("\(track.lengthText)")
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
            .padding(.leading, lilSpacing2x+lilIconLength)
            
            
            VStack {
                HStack {
                    Spacer()
                    
                    ButtonMini(systemName: "sidebar.squares.right", helpText: "Hide Match Panel")
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
}
