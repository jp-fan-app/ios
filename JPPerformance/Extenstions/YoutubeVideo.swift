//
//  YoutubeVideo.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 09.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import JPFanAppClient


extension JPFanAppClient.YoutubeVideo {

    func shortTitle() -> String {
        let jpPerformancePrefix = "JP Performance - "
        if title.hasPrefix(jpPerformancePrefix) {
            return String(title[title.index(title.startIndex, offsetBy: jpPerformancePrefix.count)...])
        } else {
            return title
        }
    }

}
