//
//  ManufacturerModel.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 19.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import RealmSwift


public class ManufacturerModel: Object {

    @objc public dynamic var id = 0
    @objc public dynamic var name = ""
    @objc public dynamic var createdAt: Date?
    @objc public dynamic var updatedAt: Date?

    public override static func primaryKey() -> String? {
        return "id"
    }

}
