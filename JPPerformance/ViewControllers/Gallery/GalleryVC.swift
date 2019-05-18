//
//  GalleryVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 17.03.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit
import ImageSlideshow


protocol GalleryVCDelegate: class {

    func galleryVCWillDismiss(_ galleryVC: GalleryVC)

}


class GalleryVC: JPBaseViewController {

    @IBOutlet weak var imageSlideshowGallery: ImageSlideshow!
    private var buttonCloseVisible = false
    @IBOutlet weak var buttonClose: UIButton!
    var dismissToFrame: CGRect?

    weak var delegate: GalleryVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Gallery"

        buttonClose.alpha = 0
        buttonCloseVisible = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gestureTapImageSlideshowGallery))
        self.imageSlideshowGallery.addGestureRecognizer(tapGesture)
    }

    @IBAction func actionButtonClose(_ sender: UIButton) {
        delegate?.galleryVCWillDismiss(self)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.view.frame = self.dismissToFrame ?? .zero
            self.buttonClose.alpha = 0
        }) { _ in
            self.view.alpha = 0
            self.view.removeFromSuperview()
            if let tabbarVC = self.parent as? JPTabBarViewController,
                let index = tabbarVC.viewControllers?.index(of: self)
            {
                tabbarVC.viewControllers?.remove(at: index)
            }
            self.removeFromParent()
        }
    }

    public func prepareWithImageSlideshow(_ imageSlideshow: ImageSlideshow) {
        imageSlideshowGallery.contentScaleMode = imageSlideshow.contentScaleMode
        imageSlideshowGallery.slideshowInterval = 0
        imageSlideshowGallery.zoomEnabled = true
        imageSlideshowGallery.setImageInputs(imageSlideshow.images)
        imageSlideshowGallery.setCurrentPage(imageSlideshow.currentPage, animated: false)
    }

    public func animateLarge() {
        imageSlideshowGallery.contentScaleMode = .scaleAspectFit
        imageSlideshowGallery.layoutSubviews()
    }

    @objc private func gestureTapImageSlideshowGallery(gesture: UITapGestureRecognizer) {
        buttonCloseVisible = !buttonCloseVisible
        UIView.animate(withDuration: 0.1) {
            self.buttonClose.alpha = self.buttonCloseVisible ? 1 : 0
        }
    }

}
