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
            if store.isMatched {
                List {
                    if !notYetMatched.isEmpty {
                        Section("Mismatched") {
                            ForEach(notYetMatched) { track in
                                HStack(spacing: Metrics.lilSpacing) {
                                    Text(track.trackNo == nil ? "?" : "\(track.trackNo!)")
                                        .font(.custom("Yanone Kaffeesatz", size: 16))
                                        .monospacedDigit()
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                        .frame(width: 15, alignment: .leading)
                                        
                                    
                                    Text(track.title ?? track.filename)
                                        .font(.custom("Yanone Kaffeesatz", size: 16))
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Text(track.lengthDisplay)
                                        .font(.custom("Yanone Kaffeesatz", size: 16))
                                        .monospacedDigit()
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, Metrics.lilIconLength)
                                .textSelection(.enabled)
                            }
                        }
                    }
                    
                    if !exactlyMatched.isEmpty {
                        Section("Matched") {
                            ForEach(exactlyMatched) { track in
                                HStack(spacing: Metrics.lilSpacing) {
                                    Text(track.matched.last!.position)
                                        .font(.custom("Yanone Kaffeesatz", size: 16))
                                        .monospacedDigit()
                                        .fontWeight(.bold)
                                        .foregroundColor(.secondary)
                                        .frame(width: 15, alignment: .leading)
                                    
                                    Text(track.matched.last!.title)
                                        .font(.custom("Yanone Kaffeesatz", size: 16))
                                        .fontWeight(.bold)
                                    
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
                                .padding(.horizontal, Metrics.lilIconLength)
                                .textSelection(.enabled)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: Metrics.lilIconLength)
                }
                // Not working in Xcode Beta 1
                // .listStyle(.inset(alternatesRowBackgrounds: true))
            } else { Text("Matching…") }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(EffectsView(material: .contentBackground,
                                blendingMode: .behindWindow))
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
