//
//  MatchView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/13.
//

import SwiftUI

struct MatchView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var store: Store
    
    @State private var result: MatchSearchResult?
    @State private var hoverArtworkPrimary: Bool = false
    
    var body: some View {
        ZStack {
            if let _ = result {
                HStack(spacing: 1) {
                    ZStack {
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
                                            .animation(.easeOut, value: store.artworkMode)
                                        
                                        image.resizable().scaledToFill()
                                            .frame(width: 256, height: 256)
                                            .cornerRadius(store.artworkMode ? 0 : 8)
                                            .shadow(color: Color.black.opacity(0.54),
                                                    radius: 7.2, x: 0, y: 2.4)
                                            .onTapGesture {
                                                store.artworkMode.toggle()
                                            }
                                            .scaleEffect(store.artworkMode ? 1.22 : 1)
                                            .animation(.easeOut, value: store.artworkMode)
                                    }
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 256, height: 256)
                                }
                                .frame(width: 312, height: 312)
                                
                                VStack {
                                    VStack(spacing: 0) {
                                        ZStack {
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(height: lilSpacing2x+lilIconLength-0.5)
                                        }
                                        
                                        if colorScheme == .light {
                                            Rectangle()
                                                .frame(width: unitLength, height: 1)
                                                .foregroundColor(Color.secondary.opacity(0.4))
                                        } else {
                                            Rectangle()
                                                .frame(width: unitLength-1, height: 1)
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
                            .frame(width: unitLength-0.5, height: unitLength)
                            .clipped()
                        }
                    }
                    
//                    ZStack {
//                        Text("No Credits")
//                    }
//                    .frame(width: unitLength-0.5, height: unitLength)
//                    .background(EffectsView(
//                        material: .contentBackground,
//                        blendingMode: .behindWindow).ignoresSafeArea())
//                    .opacity(store.artworkMode ? 1 : 0)
                }
            }
            
            if store.page == 3 && store.needMatch {
                Spacer()
                    .onAppear {
                        async {
                            result = nil
                            do { try await search() }
                            catch {
                                print(store.referenceURL!.absoluteString)
                                print(error)
                            }
                            store.needMatch = false
                        }
                    }
            }
            
            // For API testing:
//            Text("\(store.matchUrl!.absoluteString)")
//                .textSelection(.enabled)
        }
        .frame(width: unitLength, height: unitLength)
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
    
    enum SearchError: Error {
        case urlNotSucceed
    }
    
    private func search() async throws {
        let (data, response) = try await URLSession.shared.data(from: store.referenceURL!)
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else { throw SearchError.urlNotSucceed }

        do {
            let result = try JSONDecoder().decode(MatchSearchResult.self, from: data)
            withAnimation {
                self.result = result
            }
        } catch { throw error }
    }
}
