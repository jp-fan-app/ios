//
//  PerformanceBoardVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class PerformanceBoardVC: UIViewController {

    weak var performanceTableVC: PerformanceTableVC?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbeddedPerformanceTable",
            let performanceTableVC = segue.destination as? PerformanceTableVC
        {
            self.performanceTableVC = performanceTableVC
            performanceTableVC.delegate = self
        }

        if segue.identifier == "showCarModelDetail",
            let navController = segue.destination as? UINavigationController,
            let carModelDetailVC = navController.topViewController as? CarModelDetailVC,
            let carModel = sender as? JPFanAppClient.CarModel
        {
            carModelDetailVC.carModel = carModel
        }
    }

}


extension PerformanceBoardVC: PerformanceTableVCDelegate {

    func performanceTableVC(_ performanceTableVC: PerformanceTableVC, didSelect carModel: JPFanAppClient.CarModel) {
        performSegue(withIdentifier: "showCarModelDetail", sender: carModel)
    }

}
