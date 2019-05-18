//
//  JPBaseViewController.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 02.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation


class JPBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        fixBarButtonItemFonts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AnalyticsService.sharedInstance.setScreenName(navigationItem.title ?? title)
    }

    private func fixBarButtonItemFonts() {
        guard let font = UIFont(name: "Montserrat-Medium", size: 16) else { return }
        let barButtonItem = UIBarButtonItem(title: navigationItem.title, style: .plain, target: nil, action: nil)
        barButtonItem.setTitleTextAttributes([.font: font], for: .normal)
        navigationItem.backBarButtonItem = barButtonItem
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([.font: font], for: .normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([.font: font], for: .highlighted)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: font], for: .normal)
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: font], for: .highlighted)
    }
    
}
