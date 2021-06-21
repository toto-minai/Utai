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
        ScrollView(.vertical, showsIndicators: false) {
            HStack(spacing: 0) {
                ZStack {
                    Color.yellow.opacity(0.001)
                    
                    LazyVStack(alignment: .trailing, spacing: 8) {
                        ForEach(1..<13) { index in
                            SingleArtwork(index: index)
                        }
                    }
                    .padding(.vertical, 28)
                    .offset(x: store.artworkMode ? 0 : -56)
                    .opacity(store.artworkMode ? 1 : 0)
                    .animation(.spring(), value: store.artworkMode)
                    
                    // Not working to block
//                    Color.yellow
//                        .padding(.trailing, 36-8)
                }
            }
            .padding(.trailing, 132)
        }
        .frame(width: 292)
        .frame(height: 352, alignment: .top)
        .frame(width: 168, alignment: .trailing)
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

struct SingleArtwork: View {
    let index: Int
    
    @State private var hover: Bool = false
    
    var body: some View {
        Image("\(index)").resizable()
            .scaledToFit()
            .frame(height: 80)
            .cornerRadius(4)
            .shadow(color: Color.black.opacity(0.54),
                    radius: 3.6, x: 2, y: 3)
            .onHover { hovering in
                withAnimation(.spring()) {
                    hover = hovering
                }
            }
            .offset(x: hover ? 52 : 0)
            .help("Open Artwork in Browser")
    }
}
