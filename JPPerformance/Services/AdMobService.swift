//
//  AdMobService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 02.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import GoogleMobileAds


class AdMobService {

    static let sharedService = AdMobService()

    func start() {
        print("Start AdMob ...")
        GADMobileAds.sharedInstance().start { status in
            print("Start AdMob: \(status.adapterStatusesByClassName)")
        }
    }

    func adUnitIDForBottomBannerVideoDetail() -> String {
        return "ca-app-pub-8137972757715004/6908370894"
    }

    func adUnitIDForBottomBannerVideoList() -> String {
        return "ca-app-pub-8137972757715004/2624005284"
    }

    func adUnitIDForBottomBannerCarDetail() -> String {
        return "ca-app-pub-8137972757715004/7102923963"
    }

    func adUnitIDForBottomBannerCarList() -> String {
        return "ca-app-pub-8137972757715004/7990090020"
    }

    func adUnitIDForBottomBannerBoardList() -> String {
        return "ca-app-pub-8137972757715004/6840659884"
    }

    func adUnitIDForBottomBannerCarCompare() -> String {
        return "ca-app-pub-8137972757715004/3300653246"
    }

    func adUnitIDForBottomBannerVideoSerieList() -> String {
        return "ca-app-pub-8137972757715004/9181107529"
    }

    func adUnitIDForBottomBannerVideoSerieDetail() -> String {
        return "ca-app-pub-8137972757715004/4837456260"
    }

    func adUnitIDForBottomBannerLaSiSe() -> String {
        return "ca-app-pub-8137972757715004/1534933288"
    }

    func request() -> GADRequest {
        let request = GADRequest()
        request.testDevices = [
            kGADSimulatorID,
            "327e41e9af55b78c4ee8a66ba9073828" // iPhone 6S Christoph Pageler
        ]
        return request
    }

}
