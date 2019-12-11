//
//  UIFont.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 11.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


extension UIFont {

    static func dynamicSystemFont(weight: UIFont.Weight, textStyle: UIFont.TextStyle) -> UIFont {
        let font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }

}
