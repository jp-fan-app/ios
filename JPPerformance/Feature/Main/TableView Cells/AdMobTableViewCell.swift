//
//  AdMobTableViewCell.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import GoogleMobileAds


class AdMobTableViewCell: UITableViewCell {

    @IBOutlet var bannerView: GADBannerView!

    func loadAd(adId: String, rootViewController: UIViewController) {
        bannerView?.adSize = kGADAdSizeSmartBannerPortrait
        bannerView?.adUnitID = adId
        bannerView?.rootViewController = rootViewController
        bannerView?.delegate = self
        bannerView?.load(AdMob.request())
    }

}


extension AdMobTableViewCell: GADBannerViewDelegate {

}
