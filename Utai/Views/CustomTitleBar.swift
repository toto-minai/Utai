//
//  CustomTitleBar.swift
//  Utai
//
//  Created by Toto Minai on 2021/07/14.
//

import SwiftUI

struct CustomTitleBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var store: Store
    
    @State private var hovering: Bool = false
    
    var body: some View {
        if store.page == 3 && store.referenceURL == nil {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.001))
                        .onHover { value in
                            hovering = value
                        }
                    
                    VStack(spacing: 0) {
                        HStack {
                            CloseButton()
                                .frame(width: 14, height: 14)
                                .padding(.leading, Metrics.lilSpacing-(colorScheme == .light ? 0 : 1))
                            
                            Spacer()
                        }
                        .frame(height: Metrics.lilSpacing2x+Metrics.lilIconLength)
                        
                        if colorScheme == .light {
                            Rectangle()
                                .frame(width: Metrics.unitLength, height: 1)
                                .foregroundColor(Color.secondary.opacity(0.4))
                                .opacity(store.infoMode ? 1 : 0)
                        } else {
                            Rectangle()
                                .frame(width: Metrics.unitLength-2, height: 1)
                                .foregroundColor(Color.secondary.opacity(0.4))
                                .opacity(store.infoMode ? 1 : 0)
                        }
                    }
                    .background {
                        Rectangle().fill(.ultraThinMaterial)
                            .opacity(store.infoMode ? 1 : 0)
                    }
                    .offset(y: store.infoMode ? (hovering ? 0 : -(Metrics.lilSpacing2x+Metrics.lilIconLength+1)) : 0)
                    .animation(.easeOut.speed(2), value: hovering)
                    .animation(.easeOut.speed(2), value: store.infoMode)
                }
                .frame(height: Metrics.lilSpacing2x+Metrics.lilIconLength+1)
                
                Spacer()
            }
            .animation(nil, value: store.infoMode)
        } else {
            VStack(spacing: 0) {
                HStack {
                    CloseButton()
                        .frame(width: 14, height: 14)
                        .padding(.leading, Metrics.lilSpacing-(colorScheme == .light ? 0 : 1))
                    
                    Spacer()
                }
                .frame(height: Metrics.lilSpacing2x+Metrics.lilIconLength)
                    
                Spacer()
            }
        }
    }
}

struct CloseButton: NSViewRepresentable {
    @Environment(\.hostingWindow) var hostingWindow
    
    
    func makeNSView(context: Context) -> NSButton {
        return window.standardWindowButton(.closeButton)!
    }
    
    func updateNSView(_ nsView: NSButton, context: Context) { }
    
    var window: NSWindow! { hostingWindow() }
}

struct ForcingRefreshModifier: ViewModifier {
    @Binding var toggle: Bool
    
    func body(content: Content) -> some View {
        if toggle { content } else { content }
    }
}

extension View {
    func forcingRefresh(_ toggle: Binding<Bool>) -> some View {
        modifier(ForcingRefreshModifier(toggle: toggle))
    }
}
