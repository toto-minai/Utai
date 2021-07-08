//
//  Store.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import SwiftUI

class Store: ObservableObject {
    @Published var page: Int = 1
    @Published var showMatchPanel: Bool = false
    @Published var infoMode: Bool = false

    // Page 1, 2, 3
    @Published var localUnit: LocalUnit?
    @Published var remoteUnit: RemoteUnit?
    @Published var referenceResult: ReferenceResult?

    // Page 1 -> 2
    @Published var searchURL: URL?
    private func makeSearchURL() {
        let album = localUnit!.album
        let artist = localUnit!.artist
        
        var componets = URLComponents()
        componets.scheme = "https"
        componets.host = "api.discogs.com"
        componets.path = "/database/search"
        componets.queryItems = [
            URLQueryItem(name: "key", value: discogs_key),
            URLQueryItem(name: "secret", value: discogs_secret)
        ]
        
        if let album = album {
            componets.queryItems!.append(URLQueryItem(name: "q", value: album))
        }
        if let artist = artist {
            componets.queryItems!.append(URLQueryItem(name: "artist", value: artist))
        }
        
        searchURL = componets.url
    }
    
    func willSearch() {
        NSApp.keyWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        makeSearchURL()
        page = 2
    }
    
    // Page 2 -> 3
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
    }
    
    // Page 3
    @Published var isMatched: Bool = false
    @Published var masterYear: Int?
}
