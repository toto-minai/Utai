//
//  DataModels.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import Foundation
import ID3TagEditor
import AVKit

class Album: Identifiable {
    let id = UUID()
    
    var titleCandidates = Set<String>()
    var artistsCandidates = Set<String>()
    var yearCandidates = Set<Int>()
    var trackToCandidates = Set<Int>()
    var diskToCandidates = Set<Int>()
    
    var title: String?
    var artists: String?
    var year: Int?
    var trackTo: Int?
    var diskTo: Int?
    
    class Track: Identifiable {
        let id = UUID()
        
        var title: String?
        var artist: String?
        var length: Double
        var trackNo: Int?
        var diskNo: Int?
        
        let url: URL
        var filename: String
        
        var standardised: String!
        
        var matched: [ReferenceResult.Track] = []
        var isExactlyMatched: Bool = false
        
        init(title: String?, artist: String?,
             length: Double, trackNo: Int?, diskNo: Int?,
             url: URL) {
            self.title = title
            self.artist = artist
            self.length = length
            self.trackNo = trackNo
            self.diskNo = diskNo
            self.url = url
            
            self.filename = url.lastPathComponent
        }
    }
    
    var tracks = [Track]()
    
    init(urls: [URL]) {
        let editor = ID3TagEditor()
        
        for url in urls {
            do {
                if let tags = try editor.read(from: url.path) {
                    // Retrieve info for whole album
                    if let albumTitle =
                        (tags.frames[.album] as? ID3FrameWithStringContent)?.content
                        { titleCandidates.insert(albumTitle) }
                    if let albumArtists =
                        (tags.frames[.albumArtist] as? ID3FrameWithStringContent)?.content
                        { artistsCandidates.insert(albumArtists) }
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
                    if let artist = artist { artistsCandidates.insert(artist) }
                    
                    let trackNo = (tags.frames[.trackPosition] as? ID3FramePartOfTotal)?.part
                    let diskNo = (tags.frames[.discPosition] as? ID3FramePartOfTotal)?.part
                    
                    let track = Track(title: title, artist: artist,
                                      length: length, trackNo: trackNo, diskNo: diskNo,
                                      url: url)
                    
                    tracks.append(track)
                }
            } catch { print(error) }
        }
        
        if titleCandidates.count == 1 { title = titleCandidates.first }
        if artistsCandidates.count == 1 { artists = artistsCandidates.first }
        if yearCandidates.count == 1 { year = yearCandidates.first }
        if trackToCandidates.count == 1 { trackTo = trackToCandidates.first }
        if diskToCandidates.count == 1 { diskTo = diskToCandidates.first }
    }
}

extension Album {
    var isMainInfoComplete: Bool {
        titleCandidates.count   == 1 &&
        artistsCandidates.count == 1
    }
    
    var matchedCount: Int { tracks.filter { $0.isExactlyMatched }.count }
    
    func resetMatched() {
        tracks.forEach {
            $0.matched = []
            $0.isExactlyMatched = false
        }
    }
}

extension Album.Track {
    // Display in form of hh:mm:ss
    var lengthDisplay: String {
        var second = Int(length)
        let hour = second / 3600
        second -= hour * 3600
        let minute = second / 60
        second -= minute * 60
        
        return (hour > 0 ? "\(String(format: "%02d", hour)):" : "") +
            "\(String(format: "%02d", minute)):" +
            String(format: "%02d", second)
    }
}
