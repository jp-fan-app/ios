//
//  StageTiming.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 20.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import RealmSwift


public class StageTiming: Object {

    @objc public dynamic var id = 0
    @objc public dynamic var carStage: CarStage?
    @objc public dynamic var range = ""
    public let second1 = RealmOptional<Double>()
    public let second2 = RealmOptional<Double>()
    public let second3 = RealmOptional<Double>()
    @objc public dynamic var createdAt: Date?
    @objc public dynamic var updatedAt: Date?

    public override static func primaryKey() -> String? {
        return "id"
    }

}
