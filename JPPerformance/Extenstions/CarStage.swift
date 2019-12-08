//
//  CarStage.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 08.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import Foundation
import JPFanAppClient


extension JPFanAppClient.CarStage {

    func laSiSeDisplayString() -> String? {
        return lasiseInSeconds?.formattedLaSiSeDisplayString()
    }

}


extension Double {

    func formattedLaSiSeDisplayString() -> String {
        let seconds = self

        let minutesInt = Int(floor(seconds / 60.0))
        let secondsInt = Int(seconds - Double(minutesInt * 60))
        let fractionInt = Int((Double(seconds) - floor(seconds)) * 10)

        let minutesString = minutesInt < 10 ? "0\(minutesInt)" : "\(minutesInt)"
        let secondsString = secondsInt < 10 ? "0\(secondsInt)" : "\(secondsInt)"

        return "\(minutesString):\(secondsString),\(fractionInt)"
    }

}
