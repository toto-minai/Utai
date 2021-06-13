//
//  DataModels.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import Foundation
import ID3TagEditor
import AVKit

struct Album: Identifiable {
    let id = UUID()
    
    var albumTitleCandidates = Set<String>()
    var albumArtistsCandidates = Set<String>()
    var yearCandidates = Set<Int>()
    var trackToCandidates = Set<Int>()
    var diskToCandidates = Set<Int>()
    
    var title: String?
    var artists: String?
    var year: Int?
    
    struct Track: Identifiable {
        let id = UUID()
        
        var title: String?
        var artist: String?
        var length: Double?
        
        var trackNo: Int?
        var diskNo: Int?
    }
    
    var tracks = [Track]()
    
    var completed: Bool {
        albumTitleCandidates.count   == 1 &&
        albumArtistsCandidates.count == 1
    }
    
    init(urls: [URL]) {
        let editor = ID3TagEditor()
        
        for url in urls {
            do {
                if let tags = try editor.read(from: url.path) {
                    // Retrieve info for whole album
                    if let albumTitle =
                        (tags.frames[.album] as? ID3FrameWithStringContent)?.content
                        { albumTitleCandidates.insert(albumTitle) }
                    if let albumArtists =
                        (tags.frames[.albumArtist] as? ID3FrameWithStringContent)?.content
                        { albumArtistsCandidates.insert(albumArtists) }
                    if let year =
                        (tags.frames[.recordingDateTime] as? ID3FrameRecordingDateTime)?.recordingDateTime.date?.year
                        { yearCandidates.insert(year) }
                    if let trackTo =
                        (tags.frames[.trackPosition] as? ID3FramePartOfTotal)?.total
                        { trackToCandidates.insert(trackTo) }
                    if let diskTo =
                        (tags.frames[.discPosition] as? ID3FramePartOfTotal)?.total
                        { diskToCandidates.insert(diskTo) }
                    
                    // Retrieve info for a single track
                    let asset = AVURLAsset(url: url)
                    let length = CMTimeGetSeconds(asset.duration)
                    
                    let title = (tags.frames[.title] as? ID3FrameWithStringContent)?.content
                    let artist = (tags.frames[.artist] as? ID3FrameWithStringContent)?.content
                    if let artist = artist { albumArtistsCandidates.insert(artist) }
                    
                    let trackNo = (tags.frames[.trackPosition] as? ID3FramePartOfTotal)?.part
                    let diskNo = (tags.frames[.discPosition] as? ID3FramePartOfTotal)?.part
                    
                    let track = Track(title: title, artist: artist,
                                      length: length, trackNo: trackNo, diskNo: diskNo)
                    
                    tracks.append(track)
                }
            } catch { print(error) }
        }
        
        if albumTitleCandidates.count == 1 { title = albumTitleCandidates.first }
        if albumArtistsCandidates.count == 1 { artists = albumArtistsCandidates.first }
        if yearCandidates.count == 1 { year = yearCandidates.first }
    }
}
