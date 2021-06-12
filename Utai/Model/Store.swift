//
//  Store.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import Foundation

class Store: ObservableObject {
    @Published var page: Int = 1
    @Published var album: Album?
}
