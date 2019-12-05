//
//  GallerySegue.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 17.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit
import ImageSlideshow


class GallerySegue: UIStoryboardSegue {

    var initialFrame: CGRect?
    weak var initialImageSlideshow: ImageSlideshow?

    override func perform() {
        guard let initialFrame = initialFrame,
            let initialImageSlideshow = initialImageSlideshow,
            let galleryVC = destination as? GalleryVC
        else {
            fatalError()
        }

        let newParent = source.tabBarController ?? source.navigationController ?? source

        // place to initial frame and add
        newParent.addChild(galleryVC)
        galleryVC.beginAppearanceTransition(true, animated: true)
        newParent.view.addSubview(galleryVC.view)
        galleryVC.view.frame = initialFrame
        galleryVC.view.layoutIfNeeded()
        galleryVC.didMove(toParent: newParent)

        // prepare gallery
        galleryVC.prepareWithImageSlideshow(initialImageSlideshow)
        galleryVC.dismissToFrame = initialFrame

        // set delegate
        galleryVC.delegate = source as? GalleryVCDelegate

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                galleryVC.view.frame = UIScreen.main.bounds
                galleryVC.animateLarge()
                galleryVC.view.layoutIfNeeded()
                self.source.setNeedsStatusBarAppearanceUpdate()
            }) { _ in
                galleryVC.endAppearanceTransition()
            }
        }
    }

}
