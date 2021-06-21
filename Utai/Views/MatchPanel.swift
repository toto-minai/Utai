//
//  MatchPanel.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/20.
//

import SwiftUI

struct MatchPanel: View {
    @EnvironmentObject var store: Store
    @Environment(\.colorScheme) var colorScheme
    
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
                                    .padding(.horizontal, Metrics.lilIconLength+Metrics.lilSpacing+1)
                                    .textSelection(.enabled)
                                }
                                
                                // So it can make three
                                Text("Utai").foregroundColor(.clear)
                                
                                Text("Utai").foregroundColor(.clear)
                                
                            }
                        }
                        
                        Spacer()
                            .frame(height: Metrics.lilIconLength)
                    }
                    .frame(width: 314)
                    .clipped()
                    .frame(width: colorScheme == .light ? 312 : 310)
                    .clipped()
                    .listStyle(BorderedListStyle(alternatesRowBackgrounds: true))
                    .environment(\.defaultMinListRowHeight, Metrics.lilIconLength+Metrics.lilSpacing2x)
                    .environment(\.defaultMinListHeaderHeight, Metrics.lilIconLength+Metrics.lilSpacing2x)
                    // Not working in Xcode Beta 1
                    // .listStyle(.inset(alternatesRowBackgrounds: true))
                } else { Text("Matching…") }
                
                HStack {
                    Spacer()
                    
                    ButtonMini(systemName: "ellipsis.circle", helpText: "Options")
                        .padding(Metrics.lilSpacing)
                }
                .frame(height: Metrics.lilSpacing2x+Metrics.lilIconLength-1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension MatchPanel {
    var tracks: [Album.Track] {
        store.album!.tracks.sorted {
            if $0.trackNo != nil && $1.trackNo == nil { return true }
            else if $0.trackNo == nil && $1.trackNo == nil {
                let former = $0.title ?? $0.filename
                let latter = $1.title ?? $1.filename
                
                return former < latter
            } else if $0.trackNo != nil && $1.trackNo != nil
                { return $0.trackNo! < $1.trackNo! }
                
            return false
        }
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
        .padding(.horizontal, Metrics.lilIconLength+Metrics.lilSpacing+1)
        .textSelection(.enabled)
    }
}
