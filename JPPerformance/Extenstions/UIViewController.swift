//
//  UIViewController+FixOrientation.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit


extension UIViewController {

    @objc func fixInterfaceOrientationIfNeeded() {
        let currentOrientation = UIApplication.shared.statusBarOrientation
        let supportedOrientations = supportedInterfaceOrientations

        var isValidInterfaceOrientation = false
        switch currentOrientation {
        case .portrait:
            isValidInterfaceOrientation = supportedOrientations.contains(UIInterfaceOrientationMask.portrait)
        case .portraitUpsideDown:
            isValidInterfaceOrientation = supportedOrientations.contains(UIInterfaceOrientationMask.portraitUpsideDown)
        case .landscapeLeft:
            isValidInterfaceOrientation = supportedOrientations.contains(UIInterfaceOrientationMask.landscapeLeft)
        case .landscapeRight:
            isValidInterfaceOrientation = supportedOrientations.contains(UIInterfaceOrientationMask.landscapeRight)
        case .unknown:
            isValidInterfaceOrientation = false
        }

        if !isValidInterfaceOrientation {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }

}
