//
//  Preferences.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 21.10.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation


class Preferences {

    static var appStartsSinceLastReview: Int {
        get {
            return UserDefaults.standard.integer(forKey: "appStartsSinceLastReview")
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "appStartsSinceLastReview")
            UserDefaults.standard.synchronize()
        }
    }

    static var lastSync: Date? {
        get {
            guard let dateString = UserDefaults.standard.string(forKey: "lastSync") else {
                return nil
            }
            let df = ISO8601DateFormatter()
            return df.date(from: dateString)
        }
        set(value) {
            if let value = value {
                let df = ISO8601DateFormatter()
                let dateString = df.string(from: value)
                UserDefaults.standard.set(dateString, forKey: "lastSync")
            } else {
                UserDefaults.standard.set(nil, forKey: "lastSync")
            }
            UserDefaults.standard.synchronize()
        }
    }

    static var pushNotificiationsForNewVideosEnabled: Bool {
        get {
            let key = "pushNotificiationsForNewVideosEnabled"
            guard let number = UserDefaults.standard.value(forKey: key) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        set(value) {
            let key = "pushNotificiationsForNewVideosEnabled"
            UserDefaults.standard.set(NSNumber(value: value), forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    static var pushNotificiationsForCarUpdatesEnabled: Bool {
        get {
            let key = "pushNotificiationsForCarUpdatesEnabled"
            guard let number = UserDefaults.standard.value(forKey: key) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        set(value) {
            let key = "pushNotificiationsForCarUpdatesEnabled"
            UserDefaults.standard.set(NSNumber(value: value), forKey: key)
            UserDefaults.standard.synchronize()
        }
    }

    static var pushToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "pushToken")
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "pushToken")
            UserDefaults.standard.synchronize()
        }
    }

}
