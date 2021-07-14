//
//  ArtworkSidebar.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/21.
//

import SwiftUI

struct ArtworkSidebar: View {
    @ObservedObject var store: Store
    
    var body: some View {
        ZStack {
            if store.referenceResult != nil && store.referenceURL == nil {
                if let artworks = store.referenceResult!.artworks {
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ZStack {
                                Color.yellow.opacity(0.001)
                                
                                LazyVStack(alignment: .trailing, spacing: 8) {
                                    ForEach(artworks.dropFirst(), id: \.resourceURL) { artwork in
                                        SingleArtwork(artwork: artwork)
                                    }
                                }
                                .padding(.vertical, 28)
                                .offset(x: store.infoMode ? 0 : -56)
                                .opacity(store.infoMode ? 1 : 0)
                                .animation(.spring(), value: store.infoMode)
                            }
                        }
                    }
                    .frame(width: 292+8)
                    .frame(height: 339, alignment: .top)
                    .frame(width: 168+8, alignment: .trailing)
                    .clipped()
                    .mask {
                        VStack(spacing: 0) {
                            LinearGradient(colors: [Color.black, Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
                                .frame(height: 12)
                            
                            Rectangle()
                            
                            LinearGradient(colors: [Color.black, Color.black.opacity(0)], startPoint: .top, endPoint: .bottom)
                                .frame(height: 12)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
        }
    }
}

struct SingleArtwork: View {
    @Environment(\.openURL) var openURL
    
    let artwork: ReferenceResult.Artwork
    
    @State private var hover: Bool = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                Color.black.opacity(0.001)
                    .frame(width: 28)
                
                AsyncImage(url: URL(string: artwork.resourceURL)!,
                           transaction: Transaction(animation: .easeOut)) { phase in
                    switch (phase) {
                    case .empty:
                        ZStack {
                            EffectView(material: .contentBackground, blendingMode: .behindWindow)
                    
                            ProgressView()
                        }.cornerRadius(8)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: widthCalculated, height: heightCalculated)
                            .cornerRadius(4)
                            .shadow(color: Color.black.opacity(0.54),
                                    radius: 3.6, x: 0, y: 2.4)
                    case .failure:
                        ZStack {
                            EffectView(material: .contentBackground, blendingMode: .behindWindow)
                        }.cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: widthCalculated, height: heightCalculated)
            }
            .offset(x: protrude)
            
            Color.black.opacity(0.001)
                .frame(width: 32 + protrude)
                
                .onHover { hovering in
                    withAnimation(
                        .spring()
                            .speed(hovering ? speed : 1)
                    ) { hover = hovering }
                }
                .offset(x: protrude)
        }
        .padding(.trailing, 132+8)
        .onTapGesture {
            withAnimation(.spring()) { hover = false }
            openURL(URL(string: artwork.resourceURL)!)
        }
    }
}

extension SingleArtwork {
    var widthCalculated: CGFloat {
        let width = CGFloat(artwork.width)
        let height = CGFloat(artwork.height)
        let ratio = width / height
        
        if ratio > 2 {
            return 160
        } else {
            return CGFloat(80) * ratio
        }
    }
    
    var heightCalculated: CGFloat {
        let width = CGFloat(artwork.width)
        let height = CGFloat(artwork.height)
        let ratio = width / height
        
        if ratio > 2 {
            return CGFloat(160) / ratio
        } else {
            return 80
        }
    }
    
    var speed: Double {
        1 - (Double(widthCalculated) - 80) / 160 / 2
    }
    
    var protrude: CGFloat {
        hover ? (widthCalculated < 28 ? 0 : widthCalculated - 28 ) : 0
    }
}
