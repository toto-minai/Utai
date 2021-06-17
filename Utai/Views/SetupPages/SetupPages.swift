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
        }
        .offset(x: CGFloat(1 - store.page) * unitLength)
        .frame(width: unitLength, alignment: .leading)
        .clipped()
    }
}

struct ReferencesControl: View {
    @EnvironmentObject var store: Store
    
    @Binding var page: Int
    
    var body: some View {
        VStack {
            HStack(spacing: lilSpacing) {
                Spacer()
                
                ButtonMini(systemName: "book", helpText: "Read Cookbook")
                    .offset(x: 1)
                
                if store.album != nil && !store.showMatchPanel {
                    ButtonMini(systemName: "sidebar.squares.right", helpText: "Show Match")
                        .onTapGesture {
                            store.showMatchPanel = true
                        }
                        .offset(x: 0.5)
                }
            }
            .padding(lilSpacing)
            
            Spacer()
        }
    }
}
