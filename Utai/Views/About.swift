//
//  About.swift
//  Utai
//
//  Created by Toto Minai on 2021/07/04.
//

import SwiftUI

struct About: View {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Utai").fontWeight(.bold)
                    Text("\(version) (\(build))")
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
                
                VStack(spacing: 4) {
                    Text("Credits")
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                    Text("Font — [Yanone Kaffeesatz](https://yanone.de/fonts/kaffeesatz/) by Yanone").fontWeight(.bold)
                }
                
                VStack(spacing: 4) {
                    Text("Copyright (c) 2021 [Toto Minai](https://twitter.com/toto_minai)")
                        .fontWeight(.bold)
                }
            }
            .padding()
        }
        .frame(height: Metrics.unitLength)
        .ignoresSafeArea()
        .frame(height: Metrics.unitLength-Metrics.titlebarHeight)
        .frame(width: Metrics.unitLength)
        .background(EffectView(
            material: .sidebar,
            blendingMode: .behindWindow).ignoresSafeArea())
        .font(.custom("Yanone Kaffeesatz", size: 16))
    }
}
