//
//  MatchView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/13.
//

import SwiftUI

struct MatchView: View {
    @AppStorage(Settings.lengthMaxDelta) var lengthMaxDelta: Int = 15
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    let pasteboard = NSPasteboard.general
    
    @EnvironmentObject var store: Store
    
    @State private var result: ReferenceResult?
    @State private var hoverArtworkPrimary: Bool = false
    
    var body: some View {
        ZStack {
            if result != nil && store.referenceURL == nil {
                if let thumb = artworkPrimaryURL.first {
                    ZStack {
                        AsyncImage(url: thumb) { image in
                            ZStack {
                                image.resizable().scaledToFill()
                                    .frame(width: 256, height: 256)
                                    .frame(height: 128, alignment: .bottom)
                                    .cornerRadius(72)
                                    .blur(radius: 7.2)
                                    .frame(width: 248, height: 312).clipped()
                                    .offset(y: 2.4+64)
                                    .scaleEffect(store.artworkMode ? 1.22 : 1)
                                    .opacity(store.artworkMode ? 0 : 1)
                                
                                image.resizable().scaledToFill()
                                    .frame(width: 256, height: 256)
                                    .cornerRadius(store.artworkMode ? 0 : 8)
                                    .shadow(color: Color.black.opacity(0.54),
                                            radius: 7.2, x: 0, y: 2.4)
                                    .onTapGesture {
                                        withAnimation(.easeOut) {
                                            store.artworkMode.toggle()
                                        }
                                    }
                                    .scaleEffect(store.artworkMode ? 1.22 : 1)
                                    .onAppear { store.referenceURL = nil }
                            }
                        } placeholder: {
                            ProgressView()
                                .frame(width: 256, height: 256)
                        }
                        .frame(width: 312, height: 312)
                        .contextMenu {
                            Button(action: { openURL(URL(string: "\(result!.uri)")!) })
                            { Text("View on Discogs") }
                        }
                        
                        VStack {
                            VStack(spacing: 0) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(height: Metrics.lilSpacing2x+Metrics.lilIconLength-0.5)
                                }
                                
                                if colorScheme == .light {
                                    Rectangle()
                                        .frame(width: Metrics.unitLength, height: 1)
                                        .foregroundColor(Color.secondary.opacity(0.4))
                                } else {
                                    Rectangle()
                                        .frame(width: Metrics.unitLength-1, height: 1)
                                        .foregroundColor(Color.secondary.opacity(0.4))
                                        .offset(x: 0.5)
                                }
                            }
                            .background(.ultraThinMaterial)
                            
                            Spacer()
                        }
                        .opacity(store.artworkMode ? 1 : 0)
                        .animation(nil, value: store.artworkMode)
                    }
                    
                }
            } else { Text("Retrieving Data…").fontWeight(.bold) }
            
            if store.page == 3 {
                doWhenTurnToThisPage
                
                if store.referenceURL != nil { doWhenNeedToRetrieveData }
            }
        }
        .frame(width: Metrics.unitLength, height: Metrics.unitLength)
        .onAppear {  // doWhenBuildThisPage
            
        }
    }
    
    var doWhenTurnToThisPage: some View {
        void.onAppear {
            
        }
    }
    
    var doWhenNeedToRetrieveData: some View {
        void.onAppear {
            result = nil
            print(store.referenceURL!.absoluteString)

            async {
                do { try await search() }
                catch {
                    print(error)
                }
                
                store.referenceURL = nil
                
                match()
            }
        }
    }
}

extension MatchView {
    var artworkPrimaryURL: [URL] {
        if let artworks = result!.artworks {
            if artworks.filter({ $0.type == "primary" }).isEmpty {
                return [artworks.first!.resourceURL]
            }
            
            return artworks.filter {
                $0.type == "primary"
            }.map { $0.resourceURL }
        }
        
        return []
    }
    
    var tracks: [Album.Track] { store.album!.tracks }
    
    var remoteTracks: [ReferenceResult.Track] { result!.tracks }
    
    enum SearchError: Error { case badURL }
    private func search() async throws {
        let (data, response) = try await URLSession.shared.data(from: store.referenceURL!)
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else { throw SearchError.badURL }

        do {
            let result = try JSONDecoder().decode(ReferenceResult.self, from: data)
            withAnimation(.easeOut) { self.result = result }
        } catch { throw error }
    }
    
    private func match() {
        store.album!.resetMatched()
        
        for track in tracks {
            let filename = track.filename
            let title = track.title ?? (filename as NSString).deletingPathExtension
            let localTitle = title.standardised()
            // Save standardised title
            track.standardised = localTitle
            
            print(localTitle)
            
            for remoteTrack in remoteTracks {
                // Select out info, combined title, etc.
                if remoteTrack.type == "track" {
                    let remoteTitle = remoteTrack.title.standardised()
                    
                    print("\tvs.\(remoteTitle)")
                    
                    if remoteTitle == title ||
                        localTitle.contains(remoteTitle) ||
                        remoteTitle.contains(localTitle) {
                        track.matched.append(remoteTrack)
                        
                        if let length = remoteTrack.length {
                            print("\t\(Int(track.length))")
                            print("\t\(length)")
                            
                            if abs(Int(track.length) - length) <= lengthMaxDelta {
                                track.isExactlyMatched = true
                                break
                            }
                        }
                    }
                } else if remoteTrack.type == "index" {
                    if let subTracks = remoteTrack.subTracks {
                        var isMatched = false
                        for remoteSubTrack in subTracks {
                            if remoteSubTrack.type == "track" {
                                let remoteSubTrackTitle = remoteSubTrack.title.standardised()
                                
                                if remoteSubTrackTitle == title ||
                                    localTitle.contains(remoteSubTrackTitle) ||
                                    remoteSubTrackTitle.contains(localTitle) {
                                    let newTrack = ReferenceResult.Track(position: remoteSubTrack.position,
                                                                         type: remoteSubTrack.type,
                                                                         title: remoteSubTrack.title,
                                                                         extraArtists: nil,
                                                                         duration: remoteSubTrack.duration,
                                                                         subTracks: nil)
                                    
                                    track.matched.append(newTrack)
                                    
                                    if let length = remoteSubTrack.length {
                                        if abs(Int(track.length) - length) <= lengthMaxDelta {
                                            track.isExactlyMatched = true
                                            isMatched = true
                                            break
                                        }
                                    }
                                }
                            }
                        }
                        
                        if isMatched { break }
                    }
                }
            }
        }
        
        printMatchResult()
    }
    
    private func printMatchResult() {
        for track in tracks {
            print("\(track.title ?? track.filename)" + " = " + "\(String(describing: track.standardised))")
            print("matched: \(track.matched)")
            let A = track.matched.map { $0.title }
            print("i.e.: \(A)")
            print("\(track.isExactlyMatched)")
            print("--------------")
        }
    }
}

extension String {
    func symbolsRemoved() -> String {
        return String(self.map { ($0.isLetter || $0.isNumber) ? $0 : " " })
    }
    
    func whitespaceCondensed() -> String {
        let components = self.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    func standardised() -> String {
        self.lowercased().symbolsRemoved().whitespaceCondensed()
    }
}
