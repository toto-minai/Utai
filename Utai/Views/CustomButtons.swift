//
//  ButtonCus.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/13.
//

import SwiftUI

struct ButtonCus: View {
    let action: () -> Void
    let label: String
    let systemName: String
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Image(systemName: systemName)
                    .font(.system(size: 12))
                    .offset(y: -1.2)
                Text(label)
                    .fontWeight(.medium)
            }
        }
        .buttonStyle(.borderless)
        .focusable(false)
    }
}

struct ButtonMini: View {
    @State private var isHover = false
    var alwaysHover: Bool = false
    
    let systemName: String
    let helpText: String
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 12))
            .background(Color.black.opacity(0.001))
            // TODO: Add helper text
            .help(helpText)
            .opacity(alwaysHover ? 1 : (isHover ? 1 : 0.3))
            .onHover { hovering in
                isHover = hovering
            }
            .animation(.easeOut, value: isHover)
    }
}
