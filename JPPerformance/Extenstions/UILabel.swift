//
//  UILabel.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 11.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


extension UILabel {

    func dynamicFont(weight: UIFont.Weight, textStyle: UIFont.TextStyle) {
        font = UIFont.dynamicSystemFont(weight: weight, textStyle: textStyle)
        adjustsFontForContentSizeCategory = true
    }

}
