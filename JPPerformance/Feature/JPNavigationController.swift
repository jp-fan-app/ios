//
//  JPNavigationController.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class JPNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        topViewController?.presentedViewController?.supportedInterfaceOrientations ?? topViewController?.supportedInterfaceOrientations ?? .all
    }

    override var shouldAutorotate: Bool {
        topViewController?.presentedViewController?.shouldAutorotate ?? topViewController?.shouldAutorotate ?? false
    }

}
