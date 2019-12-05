//
//  AdMobService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 02.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import GoogleMobileAds


public class AdMob {

    public static func start() {
        print("Start AdMob ...")
        GADMobileAds.sharedInstance().start { status in
            print("Start AdMob: \(status.adapterStatusesByClassName)")
        }
    }

    public var adUnitIDForBottomBannerVideoDetail: String { "ca-app-pub-8137972757715004/6908370894" }

    public var adUnitIDForBottomBannerVideoList: String { "ca-app-pub-8137972757715004/2624005284" }

    public var adUnitIDForBottomBannerCarDetail: String { "ca-app-pub-8137972757715004/7102923963" }

    public var adUnitIDForBottomBannerCarList: String { "ca-app-pub-8137972757715004/7990090020" }

    public var adUnitIDForBottomBannerBoardList: String { "ca-app-pub-8137972757715004/6840659884" }

    public var adUnitIDForBottomBannerCarCompare: String { "ca-app-pub-8137972757715004/3300653246" }

    public var adUnitIDForBottomBannerVideoSerieList: String { "ca-app-pub-8137972757715004/9181107529" }

    public var adUnitIDForBottomBannerVideoSerieDetail: String { "ca-app-pub-8137972757715004/4837456260" }

    public var adUnitIDForBottomBannerLaSiSe: String { "ca-app-pub-8137972757715004/1534933288" }

    public static func request() -> GADRequest {
        let request = GADRequest()
        request.testDevices = [
            kGADSimulatorID,
            "327e41e9af55b78c4ee8a66ba9073828" // iPhone 6S Christoph Pageler
        ]
        return request
    }

}
