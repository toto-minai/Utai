//
//  SearchResult.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import Foundation

struct SearchResponse: Codable {
    struct Result: Codable {
        struct Format: Codable {
            let name: String
            let qty: String
            let descriptions: [String]?
        }

        let country: String?
        let coverImage: String?
        let genre: [String]?
        let id: Int
        let label: [String]?
        let masterURL: URL?
        let resourceURL: URL
        let style: [String]?
        let title: String
        let type: String
        let uri: String
        let year: String?
        let formats: [Format]?
        let format: [String]?

        private enum CodingKeys: String, CodingKey {
            case country
            case coverImage = "cover_image"
            case genre
            case id
            case label
            case masterURL = "master_url"
            case resourceURL = "resource_url"
            case style
            case title
            case type
            case uri
            case year
            case formats
            case format
        }
    }

    let results: [Result]
}
