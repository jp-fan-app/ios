//
//  CarImage.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 20.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import RealmSwift


public class CarImage: Object {

    @objc public dynamic var id = 0
    @objc public dynamic var carModel: CarModel?
    @objc public dynamic var copyrightInformation = ""
    @objc public dynamic var hasUpload = false
    @objc public dynamic var createdAt: Date?
    @objc public dynamic var updatedAt: Date?

    public override static func primaryKey() -> String? {
        return "id"
    }

}
