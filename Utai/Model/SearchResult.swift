//
//  SearchResult.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/12.
//

import Foundation

struct SearchResult: Codable {
    struct Pagination: Codable {
        struct Urls: Codable {
            let last: URL?
            let next: URL?
        }

        let items: Int
        let page: Int
        let pages: Int
        let perPage: Int
        let urls: Urls

        private enum CodingKeys: String, CodingKey {
            case items
            case page
            case pages
            case perPage = "per_page"
            case urls
        }
    }

    struct Results: Codable {
        struct Formats: Codable {
            let descriptions: [String]?
            let name: String
            let qty: String
            let text: String?
        }

        let country: String?
        let coverImage: String?
        let format: [String]?
        let genre: [String]?
        let id: Int
        let label: [String]?
        let masterID: Int?
        let masterURL: URL?
        let resourceURL: URL
        let style: [String]?
        let thumb: String?
        let title: String
        let type: String
        let uri: String
        let year: String?
        let formats: [Formats]?

        private enum CodingKeys: String, CodingKey {
            case country
            case coverImage = "cover_image"
            case format
            case genre
            case id
            case label
            case masterID = "master_id"
            case masterURL = "master_url"
            case resourceURL = "resource_url"
            case style
            case thumb
            case title
            case type
            case uri
            case year
            case formats
        }
    }

    let pagination: Pagination?
    let results: [Results]
}
