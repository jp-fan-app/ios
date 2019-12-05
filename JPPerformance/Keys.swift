//
//  Keys.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 18.05.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Foundation


public class Keys {

    private static func keyPlist() -> [String: Any] {
        guard let plistPath = Bundle.main.url(forResource: "Keys", withExtension: "plist") else { return [:] }
        return (NSDictionary(contentsOf: plistPath) as? [String: Any]) ?? [:]
    }

    static func youtubeKey() -> String {
        return keyPlist()["YoutubeKey"] as? String ?? ""
    }

    static func jpAPIKey() -> String {
        return keyPlist()["JPAPIKey"] as? String ?? ""
    }

}
