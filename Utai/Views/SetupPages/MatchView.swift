//
//  MatchView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/13.
//

import SwiftUI

struct MatchView: View {
    @EnvironmentObject var store: Store
    
    @State private var result: MatchSearchResult?
    
    var body: some View {
        ZStack {
//            Text("\(store.matchUrl!.absoluteString)")
//                .textSelection(.enabled)
                
            if let _ = result {
                HStack(spacing: 0) {
                    ZStack {
                        if let thumb = artworkPrimaryURL.first {
                            AsyncImage(url: thumb) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 256, height: 256)
                                    .cornerRadius(8)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 256, height: 256)
                            }
                            .padding(lilSpacing2x+lilIconLength)
                        }
                    }
                    
                    Spacer()
                }
            }
            
            if store.page == 3 && store.needMatch {
                Spacer()
                    .onAppear {
                        async {
                            result = nil
                            do { try await search() }
                            catch { print(error) }
                            store.needMatch = false
                        }
                    }
            }
        }
        .frame(width: 2*unitLength, height: unitLength)
    }
}

extension MatchView {
    var artworkPrimaryURL: [URL] {
        if let artworks = result!.artworks {
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
        let (data, response) = try await URLSession.shared.data(from: store.matchUrl!)
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
