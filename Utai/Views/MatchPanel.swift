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
    
    @State private var savedSet: Set<UUID> = []
    @State private var selection: Set<UUID> = []
    
    @FocusState private var isOptionsFocused: Bool
    @State private var forceRefreshing = false
    
    private func extraInfo(diskNo: Int, trackNo: Int, length: Int?, originalLength: Double) -> String {
        var extraInfo = "\t№ = " + (diskNo > 1 ? "\(diskNo)-" : "") +
            "\(trackNo)"
        if let length = length {
            let delta = length - Int(originalLength)
            extraInfo += ", Δ = \(delta > 0 ? "+" : "")\(delta)"
        }
        
        return extraInfo
    }
    
    private func unmatchedMenu(track: LocalUnit.Track) -> some View {
        Menu("Unmatched") {
            ForEach(unmatchedTracks) { unmatchedTrack in
                Button(unmatchedTrack.title + "\n\(extraInfo(diskNo: unmatchedTrack.diskNo, trackNo: unmatchedTrack.trackNo, length: unmatchedTrack.length, originalLength: track.length))") {
                    link(track, to: unmatchedTrack)
                }
            }
        }
    }
    
    private func suggestMenu(track: LocalUnit.Track) -> some View {
        Section("Suggestions") {
            ForEach(track.matched) { matched in
                Button(matched.title + "\n\(extraInfo(diskNo: matched.diskNo, trackNo: matched.trackNo, length: matched.length, originalLength: track.length))") {
                    link(track, to: matched)
                }
            }
        }
    }
    
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
                            .contextMenu {
                                if !track.matched.isEmpty { suggestMenu(track: track) }
                                Divider()
                                unmatchedMenu(track: track)
                            }
                    }
                } header: {
                    if showDiskNoForMismatched && mismatchedTracks.contains { $0.diskNo == diskNo } {
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
                        .contextMenu {
                            if !track.matched.isEmpty { suggestMenu(track: track) }
                            Divider()
                            unmatchedMenu(track: track)
                        }
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
                        MatchedTrackLine(track: track, savedSet: $savedSet,
                                         isRepeated: matchedTracks.filter {
                            $0.perfectMatchedTrack === track.perfectMatchedTrack
                        }.count > 1)
                            .swipeActions(allowsFullSwipe: false) {
                                Button("Unmatch") { unmatch(track) }
                            }
                            .contextMenu {
                                if (matchedTracks.filter {
                                    $0.perfectMatchedTrack === track.perfectMatchedTrack
                                }.count > 1) {
                                    Button("Unmatch Conflicts") {
                                        let id = track.perfectMatchedTrack!.id
                                        
                                        matchedTracks.forEach {
                                            if $0.perfectMatchedTrack!.id == id {
                                                unmatch($0)
                                            }
                                        }
                                    }
                                } else {
                                    Button("Unmatch") { unmatch(track) }
                                }
                            }
                    }
                } header: {
                    if showDiskNoForMatched && matchedTracks.contains { $0.perfectMatchedTrack!.diskNo == diskNo } {
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
    
    @AppStorage(Settings.preferMasterYear) var useMasterYear: Bool = false
    @AppStorage(Settings.saveConflicts) var forceSavingConflicts: Bool = false
    
    private var extraMenu: some View {
        Group {
            Section("Preferences") {
                Toggle("Prefer Master Year", isOn: $useMasterYear)
                Toggle("Force Saving Conflicts", isOn: $forceSavingConflicts)
            }
        }
    }
    
    private var footer: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack {
                Spacer()
                
                Menu { extraMenu } label: {
                    ButtonMini(systemName: "ellipsis.circle", helpText: "Options")
                        .padding(Metrics.lilSpacing)
                }
                .menuStyle(BorderlessButtonMenuStyle())
                .menuIndicator(.hidden)
                .frame(width: Metrics.lilSpacing2x+Metrics.lilIconLength,
                       height: Metrics.lilSpacing2x+Metrics.lilIconLength)
                .offset(x: 2, y: -0.5)
                .focused($isOptionsFocused)
            }
            .background(.ultraThickMaterial)
        }
    }
    
    var body: some View {
        ZStack {
            if store.page == 3 {
                Button("") {
                    isOptionsFocused = true
                    forceRefreshing.toggle()
                    
                    let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
                    let spaceKey: UInt16 = 49
                    
                    let spaceDown = CGEvent(keyboardEventSource: source, virtualKey: spaceKey, keyDown: true)
                    let spaceUp = CGEvent(keyboardEventSource: source, virtualKey: spaceKey, keyDown: false)
                    spaceDown?.flags = .maskNonCoalesced
                    spaceUp?.flags = .maskNonCoalesced
                    
                    let tap = CGEventTapLocation.cghidEventTap
                    spaceDown?.post(tap: tap)
                    spaceUp?.post(tap: tap)
                }
                    .keyboardShortcut(",", modifiers: .command)
                    .hidden()
                    .onChange(of: forceRefreshing) { _ in
                        Task {
                            isOptionsFocused = false
                        }
                    }
            }
            
            VStack(spacing: 0) {
                if store.isMatched {
                    ZStack {
                        List(selection: $selection) {
                            if !mismatchedTracks.isEmpty { mismatched }
                            
                            if !matchedTracks.isEmpty {
                                confirmedMatched
                                
                                Text(" ")
                                
                                HStack {
                                    Spacer()
                                    
                                    ButtonCus(action: tag, label: "Save Matched", systemName: "laptopcomputer.and.arrow.down")
                                        .font(.custom("Yanone Kaffeesatz", size: 16))
                                        .keyboardShortcut("s", modifiers: .command)
                                    
                                    Spacer()
                                }
                            }
                            
                            Text(" ")
                        }
                        .frame(width: 314)
                        .clipped()
                        .frame(width: colorScheme == .light ? 312 : 310)
                        .clipped()
                        .padding(.bottom, Metrics.lilIconLength+Metrics.lilSpacing2x)
                        .listStyle(.bordered(alternatesRowBackgrounds: true))
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
            
            footer
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
            DispatchQueue.main.async {
                mismatchedTracks.removeAll { $0.id == localTrack.id }
                matchedTracks.append(localTrack)
            }
        }
    }
    
    private func unmatch(_ track: LocalUnit.Track) {
        track.perfectMatchedTrack?.isPerfectMatched = false
        track.perfectMatchedTrack = nil
        withAnimation(.spring()) {
            DispatchQueue.main.async {
                matchedTracks.removeAll { $0.id == track.id }
                mismatchedTracks.append(track.copy())
            }
        }
    }
    
    private func tag() {
        let id3TagEditor = ID3TagEditor()
        let id3TagAlbum = ID32v3TagBuilder()
            .album(frame: ID3FrameWithStringContent(content: store.remoteUnit!.album))
            .recordingYear(frame: ID3FrameWithIntegerContent(value: useMasterYear && store.masterYear != nil ?
                                                                store.masterYear :
                                                                store.remoteUnit!.year))
            .genre(frame: ID3FrameGenre(genre: store.remoteUnit!.genre, description: nil))
        
        for track in matchedTracks {
            if savedSet.contains(track.id) ||
                !forceSavingConflicts && (matchedTracks.filter {
                $0.perfectMatchedTrack === track.perfectMatchedTrack
            }.count > 1) { continue }
            
            do {
                var id3Tag = id3TagAlbum
                    .title(frame: ID3FrameWithStringContent(content: track.perfectMatchedTrack!.title))
                    .discPosition(frame: ID3FramePartOfTotal(part: track.perfectMatchedTrack!.diskNo, total: store.remoteUnit!.diskMax))
                    .trackPosition(frame: ID3FramePartOfTotal(part: track.perfectMatchedTrack!.trackNo,
                                                              total: store.remoteUnit!.trackTos[track.perfectMatchedTrack!.diskNo]))
                
                if let artist = track.artist {
                    id3Tag = id3Tag.artist(frame: ID3FrameWithStringContent(content: artist))
                }
                if let composer = track.composer {
                    id3Tag = id3Tag.composer(frame: ID3FrameWithStringContent(content: composer))
                }
                if let conductor = track.conductor {
                    id3Tag = id3Tag.conductor(frame: ID3FrameWithStringContent(content: conductor))
                }
                if let contentGrouping = track.contentGrouping {
                    id3Tag = id3Tag.contentGrouping(frame: ID3FrameWithStringContent(content: contentGrouping))
                }
                if let copyright = track.copyright {
                    id3Tag = id3Tag.copyright(frame: ID3FrameWithStringContent(content: copyright))
                }
                if let encodedBy = track.encodedBy {
                    id3Tag = id3Tag.encodedBy(frame: ID3FrameWithStringContent(content: encodedBy))
                }
                if let encoderSettings = track.encoderSettings {
                    id3Tag = id3Tag.encoderSettings(frame: ID3FrameWithStringContent(content: encoderSettings))
                }
                if let fileOwner = track.fileOwner {
                    id3Tag = id3Tag.fileOwner(frame: ID3FrameWithStringContent(content: fileOwner))
                }
                if let lyricist = track.lyricist {
                    id3Tag = id3Tag.lyricist(frame: ID3FrameWithStringContent(content: lyricist))
                }
                if let mixArtist = track.mixArtist {
                    id3Tag = id3Tag.mixArtist(frame: ID3FrameWithStringContent(content: mixArtist))
                }
                if let publisher = track.publisher {
                    id3Tag = id3Tag.publisher(frame: ID3FrameWithStringContent(content: publisher))
                }
                if let subtitle = track.subtitle {
                    id3Tag = id3Tag.subtitle(frame: ID3FrameWithStringContent(content: subtitle))
                }
                if let recordingDayMonth = track.recordingDayMonth {
                    id3Tag = id3Tag.recordingDayMonth(frame: recordingDayMonth)
                }
                if let recordingHourMinute = track.recordingHourMinute {
                    id3Tag = id3Tag.recordingHourMinute(frame: recordingHourMinute)
                }
                
                // Not working
                if let attachedPictureFrontCover = track.attachedPictureFrontCover {
                    id3Tag = id3Tag.attachedPicture(pictureType: .frontCover, frame: attachedPictureFrontCover)
                }
                if let attachedPictureBackCover = track.attachedPictureBackCover {
                    id3Tag = id3Tag.attachedPicture(pictureType: .backCover, frame: attachedPictureBackCover)
                }

                let builded = id3Tag.build()
                try id3TagEditor.write(tag: builded, to: track.url.path)
                
                savedSet.insert(track.id)
            } catch { print(error) }
        }
    }
}

struct MismatchedTrackLine: View {
    @Environment(\.colorScheme) var colorScheme
    
    var track: LocalUnit.Track
    
    var body: some View {
        HStack(alignment: .top, spacing: Metrics.lilSpacing) {
            Text(track.trackNo == nil ? "_" : "\(track.trackNo!)")
                .font(.custom("Yanone Kaffeesatz", size: 16))
                .monospacedDigit()
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 15, alignment: .leading)
            
            
            CustomText(track.title ?? track.filename)
            
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

struct MatchedTrackLine: View {
    @Environment(\.colorScheme) var colorScheme
    
    let track: LocalUnit.Track
    
    @Binding var savedSet: Set<UUID>
    
    let isRepeated: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: Metrics.lilSpacing) {
            ZStack {
                ZStack {
                    Text("\(track.perfectMatchedTrack!.trackNo)")
                        .font(.custom("Yanone Kaffeesatz", size: 16))
                        .monospacedDigit()
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .frame(width: 15, alignment: .leading)
                        .opacity(savedSet.contains(track.id) ? 0 : 1)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .offset(y: -1.2)
                        .opacity(savedSet.contains(track.id) ? 1 : 0)
                }
                .opacity(isRepeated ? 0 : 1)
                
                ZStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .symbolRenderingMode(.multicolor)
                        .offset(y: -1.2)
                        .opacity(savedSet.contains(track.id) ? 0 : 1)
                    
                    Image(systemName: "checkmark.circle.trianglebadge.exclamationmark")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.yellow, .blue)
                        .offset(y: -1.2)
                        .opacity(savedSet.contains(track.id) ? 1 : 0)
                }
                .opacity(isRepeated ? 1 : 0)
            }
            
            CustomText(track.perfectMatchedTrack!.title)
            
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
