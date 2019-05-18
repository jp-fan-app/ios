//
//  Collection.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 27.06.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}
