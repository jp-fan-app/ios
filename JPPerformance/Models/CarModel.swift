//
//  CarModel.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 19.08.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import RealmSwift


public class CarModel: Object {

    public enum TransmissionType: Int, Codable {

        case manual
        case automatic

    }

    public enum AxleType: Int, Codable {

        case all
        case front
        case rear

    }


    @objc public dynamic var id = 0
    @objc public dynamic var name = ""
    @objc public dynamic var transmissionTypeInt = 0
    @objc public dynamic var axleTypeInt = 0
    public let mainImageID = RealmOptional<Int>()
    @objc public dynamic var manufacturer: ManufacturerModel?
    @objc public dynamic var createdAt: Date?
    @objc public dynamic var updatedAt: Date?

    public override static func primaryKey() -> String? {
        return "id"
    }

    public func transmissionType() -> TransmissionType? {
        return TransmissionType(rawValue: transmissionTypeInt)
    }

    public func axleType() -> AxleType? {
        return AxleType(rawValue: axleTypeInt)
    }

}
