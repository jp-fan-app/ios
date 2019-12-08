//
//  Formatter.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation


extension NumberFormatter {

    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()

    static let secondsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 3
        formatter.maximumFractionDigits = 3
        return formatter
    }()

    static let psFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.negativeSuffix = " PS"
        formatter.positiveSuffix = " PS"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let nmFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.negativeSuffix = " NM"
        formatter.positiveSuffix = " NM"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    func string(from: Double?) -> String? {
        guard let from = from else { return nil }
        return string(from: NSNumber(value: from))
    }

}
