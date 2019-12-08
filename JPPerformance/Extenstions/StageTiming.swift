//
//  StageTiming.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 07.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import JPFanAppClient


extension JPFanAppClient.StageTiming {

    var bestSecond: Double? { [second1, second2, second3].compactMap({ $0 }).min() }

}
