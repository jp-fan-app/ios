//
//  AnalyticsService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 02.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import Firebase


class AnalyticsService {

    static let sharedInstance = AnalyticsService()

    func start() {
        FirebaseApp.configure()
    }

    func setScreenName(_ screenName: String?) {
        Analytics.setScreenName(screenName, screenClass: nil)
    }

    func fire(event: Event) {
        print("Fire Event: \(event.rawValue) (DEBUG)")
        let action = event.rawValue
        Analytics.logEvent(action, parameters: [
            "category": event.category()
        ])
    }

    enum Event: String {
        case youtubeVideoPlay

        case spotlightOpenedYoutubeVideo

        case didRequestReview

        case updateCheckShowUpdateDialog
        case updateCheckCancel
        case updateCheckSkipVersion
        case updateCheckLaunchAppStore

        case iapPurchasedWithSuccess
        case iapPurchasedWithError
        case iapRestoredPurchases


        func category() -> String {
            switch self {
            case .youtubeVideoPlay:            return "youtube"
            case .spotlightOpenedYoutubeVideo: return "spotlight"

            case .didRequestReview:            return "review"

            case .updateCheckShowUpdateDialog: return "updatecheck"
            case .updateCheckCancel:           return "updatecheck"
            case .updateCheckSkipVersion:      return "updatecheck"
            case .updateCheckLaunchAppStore:   return "updatecheck"

            case .iapPurchasedWithSuccess:     return "iap"
            case .iapPurchasedWithError:       return "iap"
            case .iapRestoredPurchases:        return "iap"
            }
        }
    }

}
