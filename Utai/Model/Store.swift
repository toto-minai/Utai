//
//  Store.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import SwiftUI

class Store: ObservableObject {
    @Published var page: Int = 1
    
    @Published var album: Album?
    
    @Published var searchUrl: URL?
    @Published var needUpdate: Bool = false
    
    @Published var showMatchPanel: Bool = false
    
    func makeSearchUrl() {
        let title = album!.title
        let artists = album!.artists
        
        var componets = URLComponents()
        componets.scheme = "https"
        componets.host = "api.discogs.com"
        componets.path = "/database/search"
        componets.queryItems = [
            URLQueryItem(name: "key", value: discogs_key),
            URLQueryItem(name: "secret", value: discogs_secret)
        ]
        
        if let title = title {
            componets.queryItems!.append(URLQueryItem(name: "q", value: title))
        }
        if let artists = artists {
            componets.queryItems!.append(URLQueryItem(name: "artist", value: artists))
        }
        
        searchUrl = componets.url
        
        needUpdate = true
    }
}
