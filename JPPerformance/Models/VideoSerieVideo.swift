//
//  VideoSerieVideo.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 26.10.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import RealmSwift


public class VideoSerieVideo: Object {

    @objc public dynamic var id = 0
    @objc public dynamic var videoDescription: String?
    @objc public dynamic var youtubeVideo: YoutubeVideoModel?

    public override static func primaryKey() -> String? {
        return "id"
    }

}
