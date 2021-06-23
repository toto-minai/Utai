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
    
    @State private var mismatchedTracks: [LocalUnit.Track] = []
    @State private var matchedTracks: [LocalUnit.Track] = []
    
    private var mismatched: some View {
        Section("Mismatched (\(mismatchedTracks.count) Track\(mismatchedTracks.count == 1 ? "" : "s"))") {
            ForEach(1..<store.localUnit!.diskMax+1) { diskNo in
                Section {
                    ForEach(mismatchedTracks.filter {
                        if $0.diskNo == nil { return false }
                        
                        return $0.diskNo == diskNo
                    }.sorted {
                        if $0.trackNo != nil && $1.trackNo == nil { return false }
                        if $0.trackNo == nil || $1.trackNo == nil { return true }
                        
                        return $0.trackNo! < $1.trackNo!
                    }) { track in
                        MismatchedTrackLine(track: track)
                    }
                } header: {
                    if showDiskNoForMismatched {
                        Text("DISC \(diskNo)")
                            .font(.custom("Yanone Kaffeesatz", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(Color.secondary)
                            .padding(.leading, (colorScheme == .light ? 0 : 1))
                    }
                }

            }
            
            Section {
                ForEach(mismatchedTracks.filter { $0.diskNo == nil }.sorted {
                    if $0.trackNo != nil && $1.trackNo == nil { return false }
                    if $0.trackNo == nil || $1.trackNo == nil { return true }
                    
                    return $0.trackNo! < $1.trackNo!
                } ) { track in
                    MismatchedTrackLine(track: track)
                }
            } header: {
                if !mismatchedTracks.filter { $0.diskNo == nil }.isEmpty {
                    Text("DISK UNKNOWN")
                        .font(.custom("Yanone Kaffeesatz", size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(Color.secondary)
                        .padding(.leading, (colorScheme == .light ? 0 : 1))
                }
            }
        }
    }
    
    private var confirmedMatched: some View {
        Section("Matched (\(matchedTracks.count) Track\(matchedTracks.count == 1 ? "" : "s"))") {
            ForEach(1..<store.remoteUnit!.diskMax+1) { diskNo in
                Section {
                    ForEach(matchedTracks.filter {
                        $0.perfectMatchedTrack!.diskNo == diskNo
                    }.sorted {
                        $0.perfectMatchedTrack!.trackNo < $1.perfectMatchedTrack!.trackNo
                    }) { track in
                        MatchedTrackLine(track: track)
                    }
                } header: {
                    if showDiskNoForMatched {
                        Text("DISC \(diskNo)")
                            .font(.custom("Yanone Kaffeesatz", size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(Color.secondary)
                            .padding(.leading, (colorScheme == .light ? 0 : 1))
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if store.isMatched {
                    ZStack {
                        List {
                            if !mismatchedTracks.isEmpty { mismatched }
                            
                            if !matchedTracks.isEmpty { confirmedMatched }
                            
                            Text(" ")
                            
                            HStack {
                                Spacer()
                                
                                ButtonCus(action: tag, label: "Tag Matched Music", systemName: "laptopcomputer.and.arrow.down")
                                    .font(.custom("Yanone Kaffeesatz", size: 16))
                                
                                Spacer()
                            }
                            
                            Text(" ")
                        }
                        .frame(width: 314)
                        .clipped()
                        .frame(width: colorScheme == .light ? 312 : 310)
                        .clipped()
                        .padding(.bottom, Metrics.lilIconLength+Metrics.lilSpacing2x)
                        .listStyle(BorderedListStyle(alternatesRowBackgrounds: true))
                        .environment(\.defaultMinListRowHeight, Metrics.lilIconLength+Metrics.lilSpacing2x)
                        .environment(\.defaultMinListHeaderHeight, Metrics.lilIconLength+Metrics.lilSpacing2x)
                        
                        void.onAppear {  // Do when auto matching is completed
                            for track in store.localUnit!.tracks {
                                if track.perfectMatchedTrack != nil {
                                    matchedTracks.append(track)
                                } else {
                                    mismatchedTracks.append(track)
                                }
                            }
                        }
                    }
                } else { Text("Matching…") }
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    ButtonMini(systemName: "ellipsis.circle", helpText: "Options")
                        .padding(Metrics.lilSpacing)
                }
                .frame(height: Metrics.lilSpacing2x+Metrics.lilIconLength)
                .background(.ultraThickMaterial)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension MatchPanel {
    var showDiskNoForMismatched: Bool {
        if let diskTo = store.localUnit!.diskTo {
            return diskTo > 1
        } else { return store.localUnit!.diskMax > 1 }
    }
    
    var showDiskNoForMatched: Bool {
        store.remoteUnit!.diskTo > 1
    }
    
    var unmatchedTracks: [RemoteUnit.Track] {
        store.remoteUnit!.tracks.filter { !$0.isPerfectMatched }
    }
    
    private func link(_ localTrack: LocalUnit.Track, to remoteTrack: RemoteUnit.Track) {
        remoteTrack.isPerfectMatched = true
        localTrack.perfectMatchedTrack = remoteTrack
        withAnimation(.spring()) {
            mismatchedTracks.removeAll { $0.id == localTrack.id }
            matchedTracks.append(localTrack)
        }
    }
    
    private func tag() {
        let id3TagEditor = ID3TagEditor()
        let id3TagAlbum = ID32v3TagBuilder()
            .album(frame: ID3FrameWithStringContent(content: store.referenceResult!.title))
            .recordingYear(frame: ID3FrameWithIntegerContent(value: store.referenceResult!.year))
        
//        for track in exactlyMatched {
//
//            do {
//                let id3Tag = id3TagAlbum
//                    .title(frame: ID3FrameWithStringContent(content: track.matched.last!.title))
//                    .build()
//
//                try id3TagEditor.write(tag: id3Tag, to: track.url.path)
//
//            } catch { print(error) }
//        }
    }
}

struct MismatchedTrackLine: View {
    @Environment(\.colorScheme) var colorScheme
    
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
        .padding(.horizontal, Metrics.lilIconLength+Metrics.lilSpacing+(colorScheme == .light ? 1 : 2))
        
        
    }
}

/*
 .contextMenu {
     if !track.matched.isEmpty {
         Section("Suggestions") {
             ForEach(track.matched) { matched in
                 Button(matched.title) {
                     link(track, to: matched)
                 }
             }
         }
     }
     Divider()
     Menu("Unmatched") {
         ForEach(unmatchedTracks) { unmatchedTracks in
             Button(unmatchedTracks.title) {
                 link(track, to: unmatchedTracks)
             }
         }
     }
 }
 
 
 */

struct MatchedTrackLine: View {
    @Environment(\.colorScheme) var colorScheme
    
    var track: LocalUnit.Track
    
    var body: some View {
        HStack(alignment: .top, spacing: Metrics.lilSpacing) {
            Text("\(track.perfectMatchedTrack!.trackNo)")
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
        .padding(.horizontal, Metrics.lilIconLength+Metrics.lilSpacing+(colorScheme == .light ? 1 : 2))
    }
}
