//
//  LaSiSeVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 18.05.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class LaSiSeVC: JPBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "lasise".localized()
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title
    }

}
