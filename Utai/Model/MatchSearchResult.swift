//
//  MatchSearchResult.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/15.
//

import Foundation

struct MatchSearchResult: Codable {
    struct Artist: Codable {
        let name: String
        let anv: String?
        let join: String?
        let role: String?
        let tracks: String?
        let resourceURL: String

        private enum CodingKeys: String, CodingKey {
            case name
            case anv
            case join
            case role
            case tracks
            case resourceURL = "resource_url"
        }
    }

    struct Label: Codable {
        let name: String
        let catno: String?
        let entityType: String?
        let entityTypeName: String?
        let resourceURL: URL

        private enum CodingKeys: String, CodingKey {
            case name
            case catno
            case entityType = "entity_type"
            case entityTypeName = "entity_type_name"
            case resourceURL = "resource_url"
        }
    }

    struct Format: Codable {
        let name: String
        let qty: String?
        let descriptions: [String]
    }

    struct Track: Codable {
        let position: String
        let type: String
        let title: String
        let extraArtists: [Artist]?
        let duration: String?

        private enum CodingKeys: String, CodingKey {
            case position
            case type = "type_"
            case title
            case extraArtists = "extraartists"
            case duration
        }
    }

    struct Artwork: Codable {
        let type: String
        let resourceURL: URL
        let width: Int
        let height: Int

        private enum CodingKeys: String, CodingKey {
            case type
            case resourceURL = "resource_url"
            case width
            case height
        }
    }

    let year: Int?
    let uri: URL
    let artists: [Artist]
    let artistsSort: String?
    let labels: [Label]?
    let formats: [Format]?
    let masterURL: URL?
    let title: String
    let country: String?
    let released: String?
    let genres: [String]?
    let tracks: [Track]
    let extraArtists: [Artist]?
    let artworks: [Artwork]?

    private enum CodingKeys: String, CodingKey {
        case year
        case uri
        case artists
        case artistsSort = "artists_sort"
        case labels
        case formats
        case masterURL = "master_url"
        case title
        case country
        case released
        case genres
        case tracks = "tracklist"
        case extraArtists = "extraartists"
        case artworks = "images"
    }
}
