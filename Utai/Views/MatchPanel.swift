//
//  MatchPanel.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/20.
//

import SwiftUI
import ID3TagEditor

struct MatchPanel: View {
    @EnvironmentObject var store: Store
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if store.isMatched {
                    List {
                        if !notYetMatched.isEmpty {
                            Section("Mismatched (\(notYetMatched.count) Track\(notYetMatched.count == 1 ? "" : "s"))") {
                                ForEach(notYetMatched) { track in
                                    MismatchedTrackLine(track: track)
                                        .contextMenu {
                                            Section("Suggestions") {
                                                ForEach(track.matched) { matched in
                                                    Button(matched.title) {
                                                        link(track, to: matched)
                                                    }
                                                }
                                            }
                                            Divider()
                                            Section("Unmatched") {
                                                ForEach(unmatched) { unmatched in
                                                    Button(unmatched.title) {
                                                        link(track, to: unmatched)
                                                    }
                                                }
                                            }
                                        }
                                }
                            }
                        }
                        
                        if !exactlyMatched.isEmpty {
                            Section("Matched") {
                                ForEach(exactlyMatched) { track in
                                    HStack(alignment: .top, spacing: Metrics.lilSpacing) {
                                        Text("\(track.perfectMatchedTrack!.trackNo!)")
                                            .font(.custom("Yanone Kaffeesatz", size: 16))
                                            .monospacedDigit()
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                            .frame(width: 15, alignment: .leading)
                                        
                                        Text(track.perfectMatchedTrack!.title)
                                            .font(.custom("Yanone Kaffeesatz", size: 16))
                                            .fontWeight(.bold)
                                            .lineSpacing(4)
                                            .textSelection(.enabled)
                                        
                                        Spacer()
                                        
                                        Text(track.perfectMatchedTrack!.duration ?? "")
                                            .font(.custom("Yanone Kaffeesatz", size: 16))
                                            .monospacedDigit()
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, Metrics.lilIconLength+Metrics.lilSpacing+1)
                                    
                                }
                                
                            }
                        }
                        
                        Text(" ")
                        
                        HStack {
                            Spacer()
                            
                            ButtonCus(action: tag, label: "Tag Matched Music", systemName: "laptopcomputer.and.arrow.down")
                                .font(.custom("Yanone Kaffeesatz", size: 16))
                            
                            Spacer()
                        }
                            
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
    var tracks: [LocalUnit.Track] {
        store.localUnit!.tracks.sorted {
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
    
    var exactlyMatched: [LocalUnit.Track] {
        tracks.filter { $0.perfectMatchedTrack != nil }.sorted {
            let former = $0.perfectMatchedTrack!
            let latter = $1.perfectMatchedTrack!
            
            let formerDiskNo = former.diskNo!
            let formerTrackNo = former.trackNo!
            let latterDiskNo = latter.diskNo!
            let latterTrackNo = latter.trackNo!
            
            if formerDiskNo == latterDiskNo {
                return formerTrackNo < latterTrackNo
            } else {
                return formerDiskNo < latterDiskNo
            }
        }
    }
    
    var notYetMatched: [LocalUnit.Track] {
        tracks.filter { $0.perfectMatchedTrack == nil }
    }
    
    var unmatched: [RemoteUnit.Track] {
        store.remoteUnit!.tracks.filter { !$0.isPerfectMatched }
    }
    
    private func tag() {
        let id3TagEditor = ID3TagEditor()
        let id3TagAlbum = ID32v3TagBuilder()
            .album(frame: ID3FrameWithStringContent(content: store.referenceResult!.title))
            .recordingYear(frame: ID3FrameWithIntegerContent(value: store.referenceResult!.year))
        
        for track in exactlyMatched {
            
            do {
                let id3Tag = id3TagAlbum
                    .title(frame: ID3FrameWithStringContent(content: track.matched.last!.title))
                    .build()
            
                try id3TagEditor.write(tag: id3Tag, to: track.url.path)
            
            } catch { print(error) }
        }
    }
    
    private func link(_ localTrack: LocalUnit.Track, to remoteTrack: RemoteUnit.Track) {
        remoteTrack.isPerfectMatched = true
        localTrack.perfectMatchedTrack = remoteTrack
    }
}

struct MismatchedTrackLine: View {
    var track: LocalUnit.Track
    
    var body: some View {
        HStack(alignment: .top, spacing: Metrics.lilSpacing) {
            Text(track.trackNo == nil ? " " : "\(track.trackNo!)")
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
                Text(track.duration)
                    .font(.custom("Yanone Kaffeesatz", size: 16))
                    .monospacedDigit()
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, Metrics.lilIconLength+Metrics.lilSpacing+1)
        
    }
}
