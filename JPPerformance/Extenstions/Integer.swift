//
//  Integer.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import Foundation


extension Int {

    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }

}
