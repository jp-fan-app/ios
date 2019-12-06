//
//  ManufacturerLogoMapper.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 05.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class ManufacturerLogoMapper {

    // swiftlint:disable cyclomatic_complexity
    static func manufacturerLogo(for name: String) -> UIImage? {
        switch name.lowercased() {
        case let str where str.contains("audi"): return #imageLiteral(resourceName: "MakeLogoAudi.pdf")
        case let str where str.contains("volkswagen"): return #imageLiteral(resourceName: "MakeLogoVW")
        case let str where str.contains("bmw"): return #imageLiteral(resourceName: "MakeLogoBMW.pdf")
        case let str where str.contains("chevrolet"): return #imageLiteral(resourceName: "MakeLogoChevrolet.pdf")
        case let str where str.contains("citroen"): return #imageLiteral(resourceName: "MakeLogoCitroen2.pdf")
        case let str where str.contains("fiat"): return #imageLiteral(resourceName: "MakeLogoFiat.pdf")
        case let str where str.contains("hyundai"): return #imageLiteral(resourceName: "MakeLogoHyundai.pdf")
        case let str where str.contains("ktm"): return #imageLiteral(resourceName: "MakeLogoKTM.pdf")
        case let str where str.contains("mercedes"): return #imageLiteral(resourceName: "MakeLogoMercedes.pdf")
        case let str where str.contains("mini"): return #imageLiteral(resourceName: "MakeLogoMini.pdf")
        case let str where str.contains("nissan"): return #imageLiteral(resourceName: "MakeLogoNissan.pdf")
        case let str where str.contains("opel"): return #imageLiteral(resourceName: "MakeLogoOpel.pdf")
        case let str where str.contains("porsche"): return #imageLiteral(resourceName: "MakeLogoPorsche.pdf")
        case let str where str.contains("renault"): return #imageLiteral(resourceName: "MakeLogoRenault2.pdf")
        case let str where str.contains("skoda"): return #imageLiteral(resourceName: "MakeLogoSkoda2.pdf")
        case let str where str.contains("smart"): return #imageLiteral(resourceName: "MakeLogoSmart.pdf")
        case let str where str.contains("toyota"): return #imageLiteral(resourceName: "MakeLogoToyota.pdf")
        default: return nil
        }
    }
    // swiftlint:enable cyclomatic_complexity

}
