//
//  Store.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import Foundation
import SwiftUI

class Store: ObservableObject {
    @Published var page: Int = 1
    @Published var album: Album?
    @Published var searchResult: SearchResult?
    
    func searchOnDiscogs() {
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
        
        URLSession.shared.dataTask(with: componets.url!) { data, _, _ in
            do {
                if let data = data {
                    let result = try JSONDecoder().decode(SearchResult.self, from: data)
                    
                    withAnimation {
                        self.searchResult = result
                    }
                }
            } catch { print(error) }
        }.resume()
    }
}
