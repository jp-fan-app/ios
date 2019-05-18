//
//  JPNavigationViewController.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit


class JPNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let topViewController = topViewController else {
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        return topViewController.supportedInterfaceOrientations
    }

    override var shouldAutorotate: Bool {
        guard let topViewController = topViewController else {
            return true
        }
        return topViewController.shouldAutorotate
    }

}


extension JPNavigationViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        viewController.fixInterfaceOrientationIfNeeded()
    }

}
