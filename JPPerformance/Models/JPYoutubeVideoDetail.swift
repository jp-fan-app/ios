//
//  JPYoutubeVideoDetail.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import SwiftyJSON


struct JPYoutubeVideoDetail {

    let id: String
    let title: String
    let description: String
    let thumbnailURL: String
    let publishedAt: Date

    let tags: [String]
    let viewCount: Int
    let likeCount: Int
    let dislikeCout: Int
    let commentCount: Int

    static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.'000Z'"
        return df
    }()

    init?(json: JSON) {
        guard
            let items = json["items"].array,
            let firstItem = items.first,
            let id = firstItem["id"].string,
            let title = firstItem["snippet"]["title"].string,
            let description = firstItem["snippet"]["description"].string,
            let thumbnailURL = firstItem["snippet"]["thumbnails"]["maxres"]["url"].string,
            let publishedAtString = firstItem["snippet"]["publishedAt"].string,
            let publishedAtDate = JPYoutubeSearchResultItem.dateFormatter.date(from: publishedAtString),

            let viewCountString = firstItem["statistics"]["viewCount"].string,
            let viewCount = Int(viewCountString),
            let likeCountString = firstItem["statistics"]["likeCount"].string,
            let likeCount = Int(likeCountString),
            let dislikeCountString = firstItem["statistics"]["dislikeCount"].string,
            let dislikeCount = Int(dislikeCountString),
            let commentCountString = firstItem["statistics"]["commentCount"].string,
            let commentCount = Int(commentCountString)
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.publishedAt = publishedAtDate

        if let tagsArray = firstItem["snippet"]["tags"].array {
            self.tags = tagsArray.compactMap { $0.string }
        } else {
            self.tags = []
        }

        self.viewCount = viewCount
        self.likeCount = likeCount
        self.dislikeCout = dislikeCount
        self.commentCount = commentCount
    }

}
