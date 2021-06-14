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
            VStack {
                HStack {
                    ButtonMini(systemName: "xmark", helpText: "Close Match Panel")
                        .padding(8)
                        .onTapGesture {
                            store.showMatchPanel = false
                        }
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            ScrollView([.vertical]) {
                VStack(alignment: .leading, spacing: lilSpacing2x) {
                    Spacer().frame(height: lilIconLength)
                    
                    Text(store.page < 3 ? "Tracklist" : "Mismatched")
                        .fontWeight(.bold)
                        
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
                                            .foregroundColor(.primary)
                                        if album.artists == nil ||
                                            track.artist != nil && track.artist != album.artists! {
                                            Text("**\(track.artist!)**")
                                                .foregroundColor(.secondary)
                                        }
                                    }.padding(8)
                                        .background(EffectsView(
                                            material: .popover,
                                            blendingMode: .behindWindow).cornerRadius(4))
                                    
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
