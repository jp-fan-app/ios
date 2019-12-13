//
//  PerformanceBoardFilterHeaderView.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 07.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class PerformanceBoardFilterHeaderView: UITableViewHeaderFooterView {

    @IBOutlet var segmentedControlPerformanceFilter: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()

        if #available(iOS 13, *) {

        } else {
            segmentedControlPerformanceFilter.tintColor = .black
        }
    }

}
