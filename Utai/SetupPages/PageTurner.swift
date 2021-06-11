//
//  PageTurner.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

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
        .padding(.bottom, 2*8)
    }
}
