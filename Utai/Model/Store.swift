//
//  Store.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import Foundation

class Store: ObservableObject {
    @Published var page: Int = 2
    @Published var album: Album?
}
