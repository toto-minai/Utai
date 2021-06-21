//
//  MatchPanel.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/20.
//

import SwiftUI

struct MatchPanel: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if store.isMatched {
                    List {
                        if !notYetMatched.isEmpty {
                            Section("Mismatched") {
                                ForEach(notYetMatched) { track in
                                    MismatchedTrackLine(track: track)
                                }
                            }
                        }
                        
                        if !exactlyMatched.isEmpty {
                            Section("Matched") {
                                ForEach(exactlyMatched) { track in
                                    HStack(alignment: .top, spacing: Metrics.lilSpacing) {
                                        Text(track.matched.last!.position)
                                            .font(.custom("Yanone Kaffeesatz", size: 16))
                                            .monospacedDigit()
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                            .frame(width: 15, alignment: .leading)
                                        
                                        Text(track.matched.last!.title)
                                            .font(.custom("Yanone Kaffeesatz", size: 16))
                                            .fontWeight(.bold)
                                            .lineSpacing(4)
                                        
                                        Spacer()
                                        
                                        Text(track.matched.last!.duration?
                                                .split(separator: ":")
                                                .map { String(format: "%02d", Int($0)!) }
                                                .joined(separator: ":") ?? "")
                                            .font(.custom("Yanone Kaffeesatz", size: 16))
                                            .monospacedDigit()
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, Metrics.lilIconLength+Metrics.lilSpacing)
                                    .textSelection(.enabled)
                                }
                            }
                        }
                        
                        Spacer()
                            .frame(height: Metrics.lilIconLength)
                    }
                    .listStyle(BorderedListStyle(alternatesRowBackgrounds: true))
                    // Not working in Xcode Beta 1
                    // .listStyle(.inset(alternatesRowBackgrounds: true))
                } else { Text("Matching…") }
                
                HStack {
                    Spacer()
                    
                    ButtonMini(systemName: "ellipsis.circle", helpText: "Options")
                        .padding(Metrics.lilSpacing)
                }
                .frame(height: Metrics.lilSpacing2x+Metrics.lilIconLength)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension MatchPanel {
    var tracks: [Album.Track] {
        store.album!.tracks
    }
    
    var exactlyMatched: [Album.Track] {
        tracks.filter { $0.isExactlyMatched }.sorted {
            let former = $0.matched.last!
            let latter = $1.matched.last!
            
            if former.position.contains("-") {
                let formers = former.position.split(separator: "-")
                let latters = latter.position.split(separator: "-")
                
                if Int(formers.first!)! < Int(latters.first!)! { return true }
                
                return Int(formers.last!)! < Int(latters.last!)!
            } else if former.position.first!.isNumber {
                return Int(former.position)! < Int(latter.position)!
            } else {
                return former.position < latter.position
            }
        }
    }
    
    var notYetMatched: [Album.Track] {
        tracks.filter { !$0.isExactlyMatched }
    }
}

struct MismatchedTrackLine: View {
    var track: Album.Track
    
    var body: some View {
        HStack(alignment: .top, spacing: Metrics.lilSpacing) {
            Text(track.trackNo == nil ? "?" : "\(track.trackNo!)")
                .font(.custom("Yanone Kaffeesatz", size: 16))
                .monospacedDigit()
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 15, alignment: .leading)
            
            
            Text(track.title ?? track.filename)
                .font(.custom("Yanone Kaffeesatz", size: 16))
                .fontWeight(.bold)
                .lineSpacing(4)
            
            Spacer()
            
            ZStack(alignment: .trailing) {
                Text(track.lengthDisplay)
                    .font(.custom("Yanone Kaffeesatz", size: 16))
                    .monospacedDigit()
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, Metrics.lilIconLength+Metrics.lilSpacing)
        .textSelection(.enabled)
    }
}
