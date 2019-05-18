//
//  YoutubeVideoModel.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 20.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import RealmSwift


public class YoutubeVideoModel: Object {

    @objc public dynamic var id = 0
    @objc public dynamic var videoID = ""
    @objc public dynamic var title = ""
    @objc public dynamic var videoDescription = ""
    @objc public dynamic var thumbnailURL = ""
    @objc public dynamic var publishedAt: Date?
    @objc public dynamic var createdAt: Date?
    @objc public dynamic var updatedAt: Date?

    public let stages = LinkingObjects(fromType: CarStage.self, property: "videos")

    public override static func primaryKey() -> String? {
        return "id"
    }

}
