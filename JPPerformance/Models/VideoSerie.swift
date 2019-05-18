//
//  VideoSerie.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 26.10.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import RealmSwift


public class VideoSerie: Object {

    @objc public dynamic var id = 0

    @objc public dynamic var title: String = ""
    @objc public dynamic var videoSerieDescription: String = ""
    @objc public dynamic var isPublic: Bool = false
    @objc public dynamic var newestVideoPublishedAt: Date?
    @objc public dynamic var createdAt: Date?
    @objc public dynamic var updatedAt: Date?

    public let videos = List<VideoSerieVideo>()

    public override static func primaryKey() -> String? {
        return "id"
    }

    public func videosNewestAtFirst() -> [VideoSerieVideo] {
        return Array(videos).sorted { (video1, video2) -> Bool in
            guard let publishedAt1 = video1.youtubeVideo?.publishedAt,
                let publishedAt2 = video2.youtubeVideo?.publishedAt
            else {
                return true
            }
            return publishedAt1 > publishedAt2
        }
    }

    public func newestVideo() -> VideoSerieVideo? {
        return videosNewestAtFirst().first
    }

    public func oldestVideo() -> VideoSerieVideo? {
        return videosNewestAtFirst().last
    }

    public func localizedSerieTimeRangeString() -> String? {
        guard let newestPublishDate = newestVideo()?.youtubeVideo?.publishedAt,
            let oldestPubishDate = oldestVideo()?.youtubeVideo?.publishedAt
        else {
            return nil
        }

        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"

        let from = df.string(from: oldestPubishDate)
        let to = df.string(from: newestPublishDate)
        return "\(from) - \(to)"
    }

    public func videoForThumbnail() -> YoutubeVideoModel? {
        return videosNewestAtFirst().first(where: { $0.youtubeVideo?.thumbnailURL != nil })?.youtubeVideo
    }

    public func thumbnailURL() -> String? {
        return videoForThumbnail()?.thumbnailURL
    }

}
