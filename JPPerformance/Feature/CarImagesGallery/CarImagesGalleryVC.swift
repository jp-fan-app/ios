//
//  CarImagesGalleryVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 11.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient
import ImageSlideshow


class CarImagesGalleryVC: UIViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }

    @IBOutlet var buttonClose: UIButton!
    @IBOutlet var imageSlideshow: ImageSlideshow!

    private let http = UIApplication.appDelegate.http

    var carModel: JPFanAppClient.CarModel? {
        didSet {
            loadCarImagesForCarModel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonClose.layer.cornerRadius = buttonClose.frame.size.width / 2.0
        buttonClose.layer.masksToBounds = true

        imageSlideshow.zoomEnabled = true
        updateContentScaleModeForOrientation()

        loadCarImagesForCarModel()
    }

    private func updateContentScaleModeForOrientation() {
        let isPortrait = UIDevice.current.orientation.isPortrait
        imageSlideshow.contentScaleMode = isPortrait ? .scaleAspectFit : .scaleAspectFill
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateContentScaleModeForOrientation()
    }

    private func loadCarImagesForCarModel() {
        guard isViewLoaded else { return }
        guard let carModel = carModel else { return }
        guard let carModelID = carModel.id else { return }

        print("load images for \(carModel.name)")
        http.getCarImages(carModelId: carModelID).whenSuccess { carImages in
            print("loaded \(carImages.count) images")
            DispatchQueue.main.async {
                self.imageSlideshow.setImageInputs(carImages.map({
                    CarImageInputSource(carImage: $0, http: self.http)
                }))
            }
        }
    }

    @IBAction func actionButtonCloseTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
