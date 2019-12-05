//
//  TagLabel.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import Foundation


@IBDesignable
class TagLabel: UILabel {

    private let backgroundShapeLayer = CAShapeLayer()
    @IBInspectable var tagBackgroundColor: UIColor {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable var backgroundPadding: CGFloat {
        didSet {
            setNeedsLayout()
        }
    }

    override var isHidden: Bool {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        tagBackgroundColor = UIColor.clear
        backgroundPadding = 5
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        tagBackgroundColor = UIColor.clear
        backgroundPadding = 5
        
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let text = text else {
            backgroundShapeLayer.backgroundColor = UIColor.clear.cgColor
            return
        }

        if isHidden {
            backgroundShapeLayer.backgroundColor = UIColor.clear.cgColor
            return
        }
        
        if backgroundShapeLayer.superlayer == nil {
            backgroundShapeLayer.cornerRadius = 2
            backgroundShapeLayer.masksToBounds = true
            layer.superlayer?.insertSublayer(backgroundShapeLayer, at: 0)
        }
        
        // calculate text size
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        var textSize = (text as NSString).size(withAttributes: attributes)
        textSize.height += backgroundPadding * 2
        textSize.width += backgroundPadding * 2

        // update background layer
        let frame = layer.frame
        backgroundShapeLayer.frame = CGRect(x: frame.origin.x + frame.size.width / 2 - textSize.width / 2,
                                            y: frame.origin.y + frame.size.height / 2 - textSize.height / 2,
                                            width: textSize.width,
                                            height: textSize.height)
        backgroundShapeLayer.backgroundColor = tagBackgroundColor.cgColor

    }

}
