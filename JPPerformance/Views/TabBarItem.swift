//
//  TabBarItem.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 01.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit


class TabBarItem: UITabBarItem {
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setTitleTextAttributes([.font: UIFont(name: "Montserrat-Regular", size: 14)!],
                               for: .normal)
        
        updateTitlePosition()
        _ = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification,
                                                   object: nil,
                                                   queue: nil)
        { _ in
            self.updateTitlePosition()
        }
    }

    private func updateTitlePosition() {
        titlePositionAdjustment = UIOffset(horizontal: 0,
                                           vertical: UIApplication.shared.statusBarOrientation == .portrait ? -16.0 : 0.0)
    }

}
