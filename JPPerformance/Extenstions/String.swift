//
//  String.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 03.09.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation


extension String {

    public func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }

    public func localized(_ arg: CVarArg) -> String {
        return String(format: localized(), arg)
    }

}
