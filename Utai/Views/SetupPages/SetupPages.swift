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
        .offset(x: CGFloat(1 - store.page) * unitLength)
        .frame(width: unitLength, alignment: .leading)
        .clipped()
    }
}

struct ReferencesControl: View {
    @Binding var page: Int
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                ControlButton(systemName: "book", helpText: "Read Cookbook")
                    .padding(8)
            }
            
            Spacer()
        }
    }
}
