//
//  Store.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import SwiftUI

class Store: ObservableObject {
    @Published var album: Album?
    
    @Published var page: Int = 1
    
    @Published var showMatchPanel: Bool = false
    @Published var artworkMode: Bool = false

    
    @Published var searchURL: URL?
    private func makeSearchURL() {
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
        
        searchURL = componets.url
    }
    
    func didAlbumCompleted() {
        makeSearchURL()
        
        page = 2
    }
    
    @Published var referenceURL: URL?
    private func makeReferenceURL(from url: URL) {
        var componets = URLComponents(url: url,
                                      resolvingAgainstBaseURL: false)!
        componets.queryItems = [
            URLQueryItem(name: "key", value: discogs_key),
            URLQueryItem(name: "secret", value: discogs_secret)
        ]
        
        referenceURL = componets.url
    }
    
    func didReferencePicked(using url: URL) {
        makeReferenceURL(from: url)
        
        page = 3
        
        needMatch = true
    }
    
    @Published var needMatch: Bool = false
}
