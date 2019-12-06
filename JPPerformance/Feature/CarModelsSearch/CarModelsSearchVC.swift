//
//  CarModelsSearchVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class CarModelsSearchVC: UIViewController {

    let http = HTTP()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCarModelDetail",
            let navController = segue.destination as? UINavigationController,
            let carModelDetailVC = navController.topViewController as? CarModelDetailVC,
            let carModel = sender as? JPFanAppClient.CarModel
        {
            carModelDetailVC.carModel = carModel
        }
    }

    @IBAction func actionRandom(_ sender: Any) {
        http.getCarModels().whenSuccess { index in
            guard let first = index.first else { return }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showCarModelDetail", sender: first)
            }
        }
    }

}
