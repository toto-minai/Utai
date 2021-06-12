//
//  DataModels.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import Foundation

struct Album: Identifiable {
    let id = UUID()
    
    var titleCandidates = Set<String>()
    var artistsCandidates = Set<String>()
    var yearCandidates = Set<Int>()
    var trackToCandidates = Set<Int>()
    var diskToCandidates = Set<Int>()
    
    var title = ""
    var artists = ""
    var year = ""
    
    struct Track: Identifiable {
        let id = UUID()
        
        var trackNo: Int?
        var diskNo: Int?
        var title: String?
        var artist: String?
        
        var length: Double?
    }
    
    var tracks = [Track]()
}
