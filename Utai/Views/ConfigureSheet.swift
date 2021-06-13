//
//  ConfigureSheet.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/13.
//

import SwiftUI

struct ConfigureSheet: ViewModifier {
    let systemName: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: systemName)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.leading, -8)
            
            content
        }
        .padding([.leading], 16)
        .padding([.trailing, .bottom, .top], 8)
        .frame(width: 256, height: 256)
    }
}
