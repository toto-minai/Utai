//
//  DataModels.swift
//  Utai
//
//  Created by Toto Minai on 2021/06/11.
//

import Foundation
import ID3TagEditor
import AVKit

class LocalUnit {
    var albumCandidates = Set<String>()
    var albumArtistCandidates = Set<String>()
    var yearCandidates = Set<Int>()
    var trackToCandidates = Set<Int>()
    var diskToCandidates = Set<Int>()
    
    var album: String?
    var artist: String?
    var year: Int?
    var trackTo: Int?
    var diskTo: Int?
    
    class Track: Identifiable {
        let id = UUID()
        
        // Basic
        var title: String?
        var artist: String?
        let length: Double
        let trackNo: Int?
        let diskNo: Int?
        
        // File
        var url: URL
        
        // Extra
        let composer: String?
        let conductor: String?
        let contentGrouping: String?
        let copyright: String?
        let encodedBy: String?
        let encoderSettings: String?
        let fileOwner: String?
        let lyricist: String?
        let mixArtist: String?
        let publisher: String?
        let subtitle: String?
        let beatsPerMinute: Int?
        let originalFilename: String?
        let genre: ID3FrameGenre?
        let recordingDayMonth: ID3FrameRecordingDayMonth?
        let recordingHourMinute: ID3FrameRecordingHourMinute?
        let attachedPictureFrontCover: ID3FrameAttachedPicture?
        let attachedPictureBackCover: ID3FrameAttachedPicture?
        
        // Matched
        var perfectMatchedTrack: RemoteUnit.Track? = nil
        var matched: [RemoteUnit.Track] = []
        
        init(title: String?, artist: String?, length: Double, trackNo: Int?, diskNo: Int?, url: URL,
             composer: String?, conductor: String?, contentGrouping: String?, copyright: String?,
             encodedBy: String?, encoderSettings: String?, fileOwner: String?, lyricist: String?,
             mixArtist: String?, publisher: String?, subtitle: String?, beatsPerMinute: Int?,
             originalFilename: String?, genre: ID3FrameGenre?,
             recordingDayMonth: ID3FrameRecordingDayMonth?,
             recordingHourMinute: ID3FrameRecordingHourMinute?,
             attachedPictureFrontCover: ID3FrameAttachedPicture?,
             attachedPictureBackCover: ID3FrameAttachedPicture?) {
            self.title = title
            self.artist = artist
            self.length = length
            self.trackNo = trackNo
            self.diskNo = diskNo

            self.url = url

            self.composer = composer
            self.conductor = conductor
            self.contentGrouping = contentGrouping
            self.copyright = copyright
            self.encodedBy = encodedBy
            self.encoderSettings = encoderSettings
            self.fileOwner = fileOwner
            self.lyricist = lyricist
            self.mixArtist = mixArtist
            self.publisher = publisher
            self.subtitle = subtitle
            self.beatsPerMinute = beatsPerMinute
            self.originalFilename = originalFilename
            self.genre = genre
            self.recordingDayMonth = recordingDayMonth
            self.recordingHourMinute = recordingHourMinute
            self.attachedPictureFrontCover = attachedPictureFrontCover
            self.attachedPictureBackCover = attachedPictureBackCover
        }
    }
    
    var tracks = [Track]()
    
    init(urls: [URL]) {
        let editor = ID3TagEditor()
        
        for url in urls {
            do {
                if let tags = try editor.read(from: url.path) {
                    // Read info for whole album
                    if let album = (tags.frames[.album] as? ID3FrameWithStringContent)?.content
                        { albumCandidates.insert(album) }
                    if let albumArtist = (tags.frames[.albumArtist] as? ID3FrameWithStringContent)?.content
                        { albumArtistCandidates.insert(albumArtist) }
                    if let year = (tags.frames[.recordingDateTime] as? ID3FrameRecordingDateTime)?.recordingDateTime.date?.year
                        { yearCandidates.insert(year) }
                    if let trackTo = (tags.frames[.trackPosition] as? ID3FramePartOfTotal)?.total
                        { trackToCandidates.insert(trackTo) }
                    if let diskTo = (tags.frames[.discPosition] as? ID3FramePartOfTotal)?.total
                        { diskToCandidates.insert(diskTo) }
                    
                    // Read info for a single track
                    let asset = AVURLAsset(url: url)  // Not using ID3TagEditor
                    let length = CMTimeGetSeconds(asset.duration)
                    
                    let title = (tags.frames[.title] as? ID3FrameWithStringContent)?.content
                    let artist = (tags.frames[.artist] as? ID3FrameWithStringContent)?.content
                    if let artist = artist { albumArtistCandidates.insert(artist) }
                    let trackNo = (tags.frames[.trackPosition] as? ID3FramePartOfTotal)?.part
                    let diskNo = (tags.frames[.discPosition] as? ID3FramePartOfTotal)?.part
                    
                    // Read extra info, might not be processed during matching
                    let composer = (tags.frames[.composer] as? ID3FrameWithStringContent)?.content
                    let conductor = (tags.frames[.conductor] as? ID3FrameWithStringContent)?.content
                    let contentGrouping = (tags.frames[.contentGrouping] as? ID3FrameWithStringContent)?.content
                    let copyright = (tags.frames[.copyright] as? ID3FrameWithStringContent)?.content
                    let encodedBy = (tags.frames[.encodedBy] as? ID3FrameWithStringContent)?.content
                    let encoderSettings = (tags.frames[.encoderSettings] as? ID3FrameWithStringContent)?.content
                    let fileOwner = (tags.frames[.fileOwner] as? ID3FrameWithStringContent)?.content
                    let lyricist = (tags.frames[.lyricist] as? ID3FrameWithStringContent)?.content
                    let mixArtist = (tags.frames[.mixArtist] as? ID3FrameWithStringContent)?.content
                    let publisher = (tags.frames[.lyricist] as? ID3FrameWithStringContent)?.content
                    let subtitle = (tags.frames[.subtitle] as? ID3FrameWithStringContent)?.content
                    let beatsPerMinute = (tags.frames[.beatsPerMinute] as? ID3FrameWithIntegerContent)?.value
                    let originalFilename = (tags.frames[.originalFilename] as? ID3FrameWithStringContent)?.content
                    let genre = (tags.frames[.genre] as? ID3FrameGenre)
                    let recordingDayMonth = (tags.frames[.recordingDayMonth] as? ID3FrameRecordingDayMonth)
                    let recordingHourMinute = (tags.frames[.recordingHourMinute] as? ID3FrameRecordingHourMinute)
                    let attachedPictureFrontCover = (tags.frames[.attachedPicture(.frontCover)] as? ID3FrameAttachedPicture)
                    let attachedPictureBackCover = (tags.frames[.attachedPicture(.backCover)] as? ID3FrameAttachedPicture)
                    
                    let track = Track(title: title, artist: artist, length: length, trackNo: trackNo, diskNo: diskNo, url: url,
                                      composer: composer, conductor: conductor, contentGrouping: contentGrouping, copyright: copyright,
                                      encodedBy: encodedBy, encoderSettings: encoderSettings, fileOwner: fileOwner, lyricist: lyricist,
                                      mixArtist: mixArtist, publisher: publisher, subtitle: subtitle, beatsPerMinute: beatsPerMinute,
                                      originalFilename: originalFilename, genre: genre,
                                      recordingDayMonth: recordingDayMonth,
                                      recordingHourMinute: recordingHourMinute,
                                      attachedPictureFrontCover: attachedPictureFrontCover,
                                      attachedPictureBackCover: attachedPictureBackCover)
                    
                    tracks.append(track)
                }
            } catch { print(error) }
        }
        
        if albumCandidates.count == 1 { album = albumCandidates.first }
        if albumArtistCandidates.count == 1 { artist = albumArtistCandidates.first }
        if yearCandidates.count == 1 { year = yearCandidates.first }
        if trackToCandidates.count == 1 { trackTo = trackToCandidates.first }
        if diskToCandidates.count == 1 { diskTo = diskToCandidates.first }
    }
}

extension LocalUnit {
    var albumCandidatesSorted: [String] { Array(albumCandidates.sorted()) }
    var artistCandidatesSorted: [String] { Array(albumArtistCandidates.sorted()) }

    var isQueryComplete: Bool {
        albumCandidates.count       == 1 &&
        albumArtistCandidates.count == 1
    }
    
    var perfecMatchedCount: Int { tracks.filter { $0.perfectMatchedTrack != nil }.count }
    
    func resetMatched() {
        tracks.forEach {
            $0.perfectMatchedTrack = nil
            $0.matched = []
        }
    }
}

extension LocalUnit.Track {
    var filename: String { url.lastPathComponent }
    
    // Display length in form of h:mm:ss or m:ss
    var duration: String {
        var second = Int(length)
        let hour = second / 3600
        second -= hour * 3600
        let minute = second / 60
        second -= minute * 60
        
        let styled = (hour > 0 ? "\(String(format: "%02d", hour)):" : "") +
            "\(String(format: "%02d", minute)):" +
            String(format: "%02d", second)
        
        return styled.first! == "0" ? String(styled.dropFirst()) : styled
    }
}
