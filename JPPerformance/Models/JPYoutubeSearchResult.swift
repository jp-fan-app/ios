//
//  JPYoutubeSearchResult.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation
import SwiftyJSON


class JPYoutubeSearchResult {

    let nextPageToken: String?
    let items: [JPYoutubeSearchResultItem]

    required init?(json: JSON) {
        nextPageToken = json["nextPageToken"].string

        var tmpItems = [JPYoutubeSearchResultItem]()
        if let jsonItems = json["items"].array {
            for jsonItem in jsonItems {
                if let item = JPYoutubeSearchResultItem(json: jsonItem) {
                    tmpItems.append(item)
                }
            }
        }
        items = tmpItems
    }

}


class JPYoutubeSearchResultItem {

    let id: String
    let title: String
    let description: String
    let thumbnailURL: String
    let publishedAt: Date

    static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.'000Z'"
        return df
    }()

    required init?(json: JSON) {
        guard
            let id = json["id"]["videoId"].string,
            let title = json["snippet"]["title"].string,
            let description = json["snippet"]["description"].string,
            let thumbnailURL = json["snippet"]["thumbnails"]["high"]["url"].string,
            let publishedAtString = json["snippet"]["publishedAt"].string,
            let publishedAtDate = JPYoutubeSearchResultItem.dateFormatter.date(from: publishedAtString)
        else {
            return nil
        }

        self.id = id
        self.title = title
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.publishedAt = publishedAtDate
    }

    init(videoDetail: JPYoutubeVideoDetail) {
        self.id = videoDetail.id
        self.title = videoDetail.title
        self.description = videoDetail.description
        self.thumbnailURL = videoDetail.thumbnailURL
        self.publishedAt = videoDetail.publishedAt
    }

}
