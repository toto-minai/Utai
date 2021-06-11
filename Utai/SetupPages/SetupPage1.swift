//
//  SetupPage1.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

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
