//
//  UIApplication.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 04.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


extension UIApplication {

    // swiftlint:disable force_cast
    static var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    // swiftlint:enable force_cast
    
    static var http: HTTP { return appDelegate.http }

}
