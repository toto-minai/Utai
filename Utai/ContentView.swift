//
//  ContentView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/09.
//

import SwiftUI

let unitLength: CGFloat = 312
let titlebarHeight: CGFloat = 27

struct ContentView: View {
    @State var page = 1
    
    var body: some View {
        ZStack {
            SetupPages(page: $page)
            
            PageTurner(page: $page)
        }
        .font(.custom("Yanone Kaffeesatz", size: 16))
        // Translucent background
        .frame(width: unitLength, height: unitLength)
        .ignoresSafeArea()
        .frame(width: unitLength, height: unitLength-titlebarHeight)
        .background(EffectsView(
            material: .sidebar,
            blendingMode: .behindWindow).ignoresSafeArea())
    }
}

struct SetupPages: View {
    @Binding var page: Int
    
    var body: some View {
        HStack(spacing: 0) {
            SetupPage1(page: $page)
        }
        .offset(x: CGFloat(1 - page) * unitLength)
        .frame(width: unitLength, alignment: .leading)
        .clipped()
    }
}

struct PageTurnerControl: View {
    @Binding var page: Int
    @State private var isHover = false
    
    let toPage: Int
    let systemName: String
    // let helpText: String
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 12))
            // .help(helpTExt)
            .opacity(page == toPage ? 1 : (isHover ? 1 : 0.3))
            .onHover { hovering in
                isHover = hovering
            }
            .animation(.easeOut, value: isHover)
    }
}

struct PageTurner: View {
    @Binding var page: Int
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 8) {
                PageTurnerControl(page: $page, toPage: 1, systemName: "circle.fill")
                    .onTapGesture {
                        withAnimation(.spring()) {
                            page = 1
                            
                            // TODO
                        }
                    }
                
                PageTurnerControl(page: $page, toPage: 2, systemName: "triangle.fill")
                    .onTapGesture {
                        if page != 2 {
                            page = 2
                        }
                    }
                
                PageTurnerControl(page: $page, toPage: 3, systemName: "square.fill")
            }
        }
        .padding(.bottom, 8)
    }
}

//struct MusicDropDelegate: DropDelegate {
//    @Binding var pageIndex: Int
//}

struct Album: Identifiable {
    let id = UUID()
    
    var titleCandidates = Set<String>()
    var artistsCandidates = Set<String>()
    var yearCandidates = Set<Int>()
    var trackToCandidates = Set<Int>()
    var diskToCandidates = Set<Int>()
    
    var title = ""
    var artists = ""
    var year = ""
    
    struct Track: Identifiable {
        let id = UUID()
        
        var trackNo: Int?
        var diskNo: Int?
        var title: String?
        var artist: String?
        
        var length: Double?
    }
    
    var tracks = [Track]()
}

struct SetupPage1: View {
    @Binding var page: Int
    
    @State private var dragOver = false
    
    var body: some View {
        return ZStack {
            VStack {
                Text("**I. Import**")
                
                Spacer()
            }
            .padding(.top, 8+1)
            
            VStack(spacing: 8) {
                Image("WelcomeAlbum")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 120)
                    .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
                
                HStack(spacing: 4) {
                    Text("**Drag** or")
                    
                    Button(action: {}) {
                        Text("**Add Music**")
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            
        }
        .frame(width: unitLength, height: unitLength)
    }
}
