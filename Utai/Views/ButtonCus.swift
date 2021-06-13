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
            HStack(spacing: 0) {
                Image(systemName: systemName)
                    .font(.system(size: 12))
                    .offset(y: -1.2)
                Text(label)
                    .fontWeight(.bold)
            }
        }
        .buttonStyle(.borderless)
        .focusable(false)
        .shadow(radius: 2)
    }
}
