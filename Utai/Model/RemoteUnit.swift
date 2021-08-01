//
//  RemoteTrack.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/23.
//

import Foundation
import ID3TagEditor

class RemoteUnit {
    let album: String
    let year: Int?
    let artist: String?
    let genre: ID3Genre?
    let format: String?
    let diskTo: Int
    let trackTos: [Int]
    let diskMax: Int
    
    class Track: Identifiable {
        let id = UUID()
        
        // Basic
        let title: String
        let duration: String?
        let trackNo: Int
        let diskNo: Int
        let extraArtists: [String: [(String, String)]]?
        
        var isPerfectMatched: Bool = false
        
        init(title: String, duration: String?, trackNo: Int, diskNo: Int, extraArtists: [ReferenceResult.Artist]?) {
            self.title = title
            self.duration = duration
            self.trackNo = trackNo
            self.diskNo = diskNo
            
            if let extraArtists = extraArtists {
                var dict = [String: [(String, String)]]()
                
                extraArtists.forEach {
                    if dict[$0.role] != nil {
                        dict[$0.role]!.append(($0.name, $0.anv))
                    } else {
                        dict[$0.role] = [($0.name, $0.anv)]
                    }
                    
                }
                
                self.extraArtists = dict
                
            } else {
                self.extraArtists = nil
            }
        }
    }
    
    var tracks = [Track]()
    
    let genreConverted: [String: ID3Genre] = [
        "Blues": .blues,
        "Classical": .classical,
        "Electronic": .electronic,
        "Hip-Hop": .hipHop,
        "Jazz": .jazz,
        "Pop": .pop,
        "Reggae": .reggae,
        "Rock": .rock,
    ]
    
    init(result: ReferenceResult) {
        self.album = result.title
        self.year = result.year
        self.artist = result.artistsSort  // TODO: Get it right
        
        if let genres = result.genres,
           let converted = genreConverted[genres.first!] {
            self.genre = converted
        } else { self.genre = nil }
        
        let formats = result.formats
        self.format = formats?.first!.name ?? nil
        self.diskTo = formats == nil ? 1 : Int(formats!.first!.qty)!
        var trackTos = [Int]()
        
        let tracks = result.tracks.filter { $0.type == "track" || $0.type == "index" }
        
        var count = 0
        var disk = 0
        var diskText = ""
        for track in tracks {
            if track.type == "index" {
                for subTrack in track.subTracks! {
                    if subTrack.position.contains("Video") { continue }
                    
                    if let format = self.format, format.contains("CD"),
                    self.diskTo > 1 && subTrack.position.contains("-") {
                        let new = String(subTrack.position.split(separator: "-").first!)
                        
                        if new != diskText {
                            trackTos.append(count)
                            count = 0
                            disk += 1
                            diskText = new
                        }
                        
                        count += 1
                        self.tracks.append(Track(title: subTrack.title, duration: subTrack.duration,
                                                 trackNo: count, diskNo: disk, extraArtists: track.extraArtists))  // TODO: subTrack
                    } else {
                        count += 1
                        self.tracks.append(Track(title: subTrack.title, duration: subTrack.duration,
                                                 trackNo: count, diskNo: 1, extraArtists: track.extraArtists))
                    }
                }
            } else {
                if track.position.contains("Video") { continue }
                
                if let format = self.format, format.contains("CD"),
                self.diskTo > 1 && track.position.contains("-") {
                    let new = String(track.position.split(separator: "-").first!)
                    
                    if new != diskText {
                        trackTos.append(count)
                        count = 0
                        disk += 1
                        diskText = new
                    }
                    
                    count += 1
                    self.tracks.append(Track(title: track.title, duration: track.duration,
                                             trackNo: count, diskNo: disk, extraArtists: track.extraArtists))
                } else {
                    count += 1
                    self.tracks.append(Track(title: track.title, duration: track.duration,
                                             trackNo: count, diskNo: 1, extraArtists: track.extraArtists))
                }
            }
        }
        
        self.diskMax = disk == 0 ? 1 : disk
        if disk != 0 {
            trackTos.append(count)
        }
        
        if self.diskTo > 1 {
            self.trackTos = trackTos
        } else {
            self.trackTos = [0, count]
        }
    }
}

extension RemoteUnit.Track {
    var length: Int? {
        if let duration = duration {
            if duration == "" { return nil }
            
            let multiply = [1, 60, 3600]
            var numbers = duration.components(separatedBy: ":").map { Int($0)! }
            
            let cnt = numbers.count
            for i in 0..<min(multiply.count, cnt) {
                numbers[cnt-i-1] *= multiply[i]
            }
            
            return numbers.reduce(0, +)
        }
        
        return nil
    }
}
