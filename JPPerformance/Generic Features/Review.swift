//
//  ReviewService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 22.10.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation
import StoreKit


class Review {

    static func increaseAppStartCount() {
        var i = Preferences.appStartsSinceLastReview
        i += 1
        Preferences.appStartsSinceLastReview = i

        print("App Starts: \(i)")
    }

    static func requestReviewIfNeeded(userDemonstratedEngagement: Bool = false) {
        guard isReviewNeeded(userDemonstratedEngagement: userDemonstratedEngagement) else { return }

        if ProcessInfo.processInfo.arguments.contains("TAKING_SCREENSHOTS") {
            return
        }

        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            resetAppStartCount()
        } else {
            // Fallback on earlier versions
        }
    }

    private static func resetAppStartCount() {
        Preferences.appStartsSinceLastReview = 0
        print("Reset App Starts")
    }

    private static func isReviewNeeded(userDemonstratedEngagement: Bool) -> Bool {
        let i = Preferences.appStartsSinceLastReview
        return (userDemonstratedEngagement && i > 10) || (!userDemonstratedEngagement && i > 20)
    }

}
