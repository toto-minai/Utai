//
//  MatchView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/13.
//

import SwiftUI

struct MatchView: View {
    @AppStorage(Settings.lengthMaxDelta) var lengthMaxDelta: Int = 15
    
    let pasteboard = NSPasteboard.general
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @Environment(\.hostingWindow) var hostingWindow
    @State private var subWindow: NSWindow!
    
    @EnvironmentObject var store: Store
    
    @State private var resultSaved: ReferenceResult?
    
    var body: some View {
        ZStack {
            if store.page == 3 {
                Button("") { store.artworkMode.toggle() }
                    .keyboardShortcut("i", modifiers: .command)
                    .hidden()
            }
            
            if store.referenceResult != nil && store.referenceURL == nil {
                doWhenNeedToGetMasterYear
                
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
                                    .animation(store.page == 3 ? .easeOut : .none, value: store.artworkMode)
                                
                                image.resizable().scaledToFill()
                                    .frame(width: 256, height: 256)
                                    .cornerRadius(store.artworkMode ? 0 : 8)
                                    .shadow(color: Color.black.opacity(0.54),
                                            radius: 7.2, x: 0, y: 2.4)
                                    .onTapGesture {
                                        store.artworkMode.toggle()
                                    }
                                    .scaleEffect(store.artworkMode ? 1.22 : 1)
                                    .onAppear { store.referenceURL = nil }
                                    .animation(store.page == 3 ? .easeOut : .none, value: store.artworkMode)
                            }
                        } placeholder: { ProgressView() }
                        .frame(width: 312, height: 312)
                        .contextMenu {
                            Button(action: { openURL(URL(string: "\(store.referenceResult!.uri)")!) })
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
                                        .frame(width: Metrics.unitLength-2, height: 1)
                                        .foregroundColor(Color.secondary.opacity(0.4))
                                }
                            }
                            .background {
                                EffectsView(material: .titlebar, blendingMode: .withinWindow)
                            }
                            
                            Spacer()
                        }
                        .opacity(store.artworkMode ? 1 : 0)
                        .animation(nil, value: store.artworkMode)
                    }
                    
                }
            } else { ProgressView() }
            
            if store.page == 3 {
                doWhenTurnToThisPage
                
                if store.referenceURL != nil { doWhenNeedToRetrieveData }
            }
        }
        .frame(width: Metrics.unitLength, height: Metrics.unitLength)
        .onAppear {  // doWhenBuildThisPage
            subWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 168, height: 352),
                                 styleMask: [], backing: .buffered, defer: false)
            
            let rootView = ArtworkSidebar(store: store)
            subWindow.setFrameAutosaveName("Artwork Sidebar")
            
            subWindow.titleVisibility = .hidden
            subWindow.backgroundColor = NSColor.clear
            subWindow.hasShadow = false
            
            subWindow.contentView = NSHostingView(rootView: rootView)
        }
    }
    
    var doWhenTurnToThisPage: some View {
        void.onAppear {
            let frame = window.frame
            subWindow.setFrameOrigin(NSPoint(x: frame.minX+312, y: frame.maxY-339))
            window.addChildWindow(subWindow, ordered: .below)
        }
        .onDisappear {
            subWindow.orderOut(nil)
            if window != nil {
                window.removeChildWindow(subWindow)
            }
        }
    }
    
    var doWhenNeedToRetrieveData: some View {
        void.onAppear {
            store.referenceResult = nil
            store.masterYear = nil

            Task {
                do { try await search() }
                catch {
                    print(error)
                }
                
                store.referenceURL = nil
                store.referenceResult = resultSaved
                
                let frame = window.frame
                subWindow.setFrameOrigin(NSPoint(x: frame.minX+312, y: frame.maxY-339))
                window.addChildWindow(subWindow, ordered: .below)
                
                match()
            }
        }
    }
    
    var doWhenNeedToGetMasterYear: some View {
        void.task {
            if let url = resultSaved!.masterURL {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
                    do {
                        let result = try JSONDecoder().decode(ReferenceResult.self, from: data)
                        store.masterYear = result.year
                    } catch { print(error) }
                } catch { print(error) }
            }
        }
    }
}

extension MatchView {
    private var window: NSWindow! { self.hostingWindow() }
    
    private var artworkPrimaryURL: [URL] {
        if let artworks = store.referenceResult!.artworks {
            if artworks.filter({ $0.type == "primary" }).isEmpty {
                return [URL(string: artworks.first!.resourceURL)!]
            }
            
            return artworks.filter {
                $0.type == "primary"
            }.map { URL(string: $0.resourceURL)! }
        }
        
        return []
    }
    
    private var localTracks: [LocalUnit.Track] { store.localUnit!.tracks }
    private var remoteTracks: [RemoteUnit.Track] { store.remoteUnit!.tracks }
    
    enum SearchError: Error { case badURL }
    private func search() async throws {
        let (data, response) = try await URLSession.shared.data(from: store.referenceURL!)
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else { throw SearchError.badURL }

        do {
            let result = try JSONDecoder().decode(ReferenceResult.self, from: data)
            withAnimation(.easeOut) { resultSaved = result }
        } catch { throw error }
    }
    
    private func match() {
        store.localUnit!.resetMatched()
        store.remoteUnit = RemoteUnit(result: resultSaved!)
        
        for localTrack in localTracks {
            let filename = localTrack.filename
            let title = localTrack.title ?? (filename as NSString).deletingPathExtension
            let localTitle = title.standardised()

            for remoteTrack in remoteTracks {
                let remoteTitle = remoteTrack.title.standardised()
                
                if remoteTitle == localTitle {
                    if remoteTrack.length != nil &&
                        abs(Int(localTrack.length) - remoteTrack.length!) <= lengthMaxDelta {
                        remoteTrack.isPerfectMatched = true
                        localTrack.perfectMatchedTrack = remoteTrack
                        break
                    }
                } else if !remoteTrack.isPerfectMatched {
                    let remoteTitleWords = remoteTitle.split(separator: " ")
                    var remoteTitleAppearedWords = Set<Substring>()
                    var hasWildcard = false
                    var remoteTitleWord2Token = [Substring:Character]()
                    var remoteTitleTokens = [Character]()
                    var delta: UInt8 = 0
                    
                    for word in remoteTitleWords {
                        if Int(word) != nil || word == "the" { hasWildcard = true }
                        
                        if !remoteTitleAppearedWords.contains(word) {
                            remoteTitleAppearedWords.insert(word)
                            let character = Character(UnicodeScalar(Character("0").asciiValue! + delta))
                            remoteTitleWord2Token[word] = character
                            remoteTitleTokens.append(character)
                            delta += 1
                        } else {
                            remoteTitleTokens.append(remoteTitleWord2Token[word]!)
                        }
                    }
                    
                    let localTitleWords = localTitle.split(separator: " ")
                    var localTitleTokens = [Character]()
                    
                    for word in localTitleWords {
                        if remoteTitleWord2Token[word] != nil {
                            localTitleTokens.append(remoteTitleWord2Token[word]!)
                        } else {
                            localTitleTokens.append(Character(" "))
                        }
                    }
                    
                    let remoteTitleTokenString = remoteTitleTokens.map { String($0) }.reduce("", +)
                    let localTitleTokenString = localTitleTokens.map { String($0) }.reduce("", +).trimmingCharacters(in: .whitespaces)
                    
                    if localTitleTokenString.count > (hasWildcard ? 1 : 0) && remoteTitleTokenString.contains(localTitleTokenString) {
                        if remoteTrack.length != nil {
                            if abs(Int(localTrack.length) - remoteTrack.length!) <= lengthMaxDelta {
                                localTrack.matched.append(remoteTrack)
                            }
                        }
                        
                        print("-----------------")
                        print(localTitleTokenString)
                        print(remoteTitleTokenString)
                        print(localTitle)
                        print(remoteTitle)
                        print(localTitleTokenString.count > (hasWildcard ? 1 : 0) && remoteTitleTokenString.contains(localTitleTokenString))
                        print("~~~~~~~~~~~~~~~")
                    }
                    
                }
            }
        }
        
        store.isMatched = true
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
