//
//  ViewController.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 16.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit


class JPInitialViewController: UIViewController {

    public private(set) var tabBarViewController: JPTabBarViewController?
    private var shouldShowConfigAlert: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let deadlineTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            if self.shouldShowConfigAlert {
                self.showConfigAlert()
            } else {
                self.transitionToApp()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail", let tabBarVC = segue.destination as? JPTabBarViewController {
            tabBarViewController = tabBarVC
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }

    @IBAction func actionHiddenButton(_ sender: UIButton) {
        shouldShowConfigAlert = true
    }

    private func showConfigAlert() {
        let alertController = UIAlertController(title: "Configuration",
                                                message: "Select Configuration",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Production", style: .default, handler: { (alert) in
            CarService.prepareForProduction()
            self.transitionToApp()
        }))
        alertController.addAction(UIAlertAction(title: "Staging", style: .destructive, handler: { (alert) in
            CarService.prepareForStaging()
            self.transitionToApp()
        }))
        present(alertController, animated: true, completion: nil)
    }

    private func transitionToApp() {
        performSegue(withIdentifier: "showDetail", sender: nil)
    }

}
