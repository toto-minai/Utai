//
//  ChooseView.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import SwiftUI

struct ChooseView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        if store.page == 2 {
            ZStack(alignment: .top) {
                Rectangle()
                    .frame(height: 84)
                    .foregroundColor(.clear)
                    .background(LinearGradient(stops: [Gradient.Stop(color: Color.white.opacity(0), location: 0),
                                                       Gradient.Stop(color: Color.white.opacity(0.1), location: 0.3),
                                                       Gradient.Stop(color: Color.white.opacity(0), location: 1)],
                                               startPoint: .top, endPoint: .bottom))
                    .offset(y: 108)
                
                VStack(spacing: 16) {
                    Spacer().frame(height: 12+8)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 2*8+12)
                            
                            Text("**Ornette Coleman**")
                                .foregroundColor(.secondary)
                            Text(" – ")
                            Text("**Town Hall (1962)**")
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Spacer().frame(width: 8+12)
                            
                            ForEach(1..<5) { index in
                                Image("\(index)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80)
                                    .cornerRadius(4)
                                    .shadow(color: Color.black.opacity(0.4), radius: 4, x: 0, y: 4)
                                    .frame(height: 100)
                            }
                            
                            Spacer().frame(width: 8+12)
                        }
                    }
                    .padding(.vertical, -10)
                    
                    HStack(spacing: 8) {
                        Button(action: {}) {
                            HStack(spacing: 2) {
                                Image(systemName: "slider.vertical.3")
                                    .font(.system(size: 12))
                                    .offset(y: -1.2)
                                Text("**Settings**")
                            }
                        }
                        .buttonStyle(.borderless)
                        
                        Button(action: {}) {
                            HStack(spacing: 2) {
                                Image(systemName: "smallcircle.fill.circle.fill")
                                    .font(.system(size: 12))
                                    .offset(y: -1.2)
                                Text("**Pick It**")
                            }
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Spacer().frame(width: 2*8+12)
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("**Versus**")
                                Text("**Format**")
                                Text("**Released**")
                            }
                            .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("**Ornette Coleman – Town Hall • 1962**")
                                Text("**Vinyl / LP / Album / Mono**")
                                Text("**1965 🇺🇸**")
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: unitLength, height: unitLength)
            }
        }
    }
}
