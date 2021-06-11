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
                Text("I. **Import**")
                
                Spacer()
            }
            .padding(.top, 8)
            
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .foregroundColor(Color.black.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image("SimpleIcon")
                        .resizable()
                        .aspectRatio(1.25, contentMode: .fit)
                        .frame(width: 54)
                        .foregroundColor(Color.white.opacity(0.4))
                }
                
                HStack(spacing: 2) {
                    Text("**Drag** or")
                    
                    Button(action: {}) {
                        Text("**Add Music**")
                    }
                    .buttonStyle(.borderless)
                }
            }
            .offset(y: -8)
            
            
        }
        .frame(width: unitLength, height: unitLength)
    }
}
