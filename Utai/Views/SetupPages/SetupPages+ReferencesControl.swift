//
//  SetupPages.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import SwiftUI

struct SetupPages: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        HStack(spacing: 0) {
            ImportView()
            
            ChooseView()
            
            MatchView()
        }
        .offset(x: CGFloat(1 - store.page) * Metrics.unitLength)
        .animation(nil, value: store.page)
        .frame(width: Metrics.unitLength, alignment: .leading)
        .clipped()
    }
}

struct ReferencesControl: View {
    @EnvironmentObject var store: Store
    
    @Binding var page: Int
    
    var body: some View {
        VStack {
            HStack(spacing: Metrics.lilSpacing) {
                Spacer()
                
                ButtonMini(systemName: "book", helpText: "Read Cookbook")
                    .padding(Metrics.lilSpacing)
            }
            
            Spacer()
        }
        .frame(height: Metrics.unitLength)
        .opacity(0)
    }
}
