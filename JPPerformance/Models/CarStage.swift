//
//  CarStage.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 20.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import RealmSwift


public class CarStage: Object {

    @objc public dynamic var id = 0
    @objc public dynamic var carModel: CarModel?
    @objc public dynamic var name = ""
    @objc public dynamic var stageDescription = ""
    @objc public dynamic var isStock = false
    public let ps = RealmOptional<Double>()
    public let nm = RealmOptional<Double>()
    @objc public dynamic var createdAt: Date?
    @objc public dynamic var updatedAt: Date?

    public let videos = List<YoutubeVideoModel>()

    public override static func primaryKey() -> String? {
        return "id"
    }

}
