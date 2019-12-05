//
//  JPCarDetailVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 23.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import ImageSlideshow
import GoogleMobileAds


class JPCarDetailVC: JPBaseViewController {

    var carItem: JPCarItem?

    var expandedSectionIndex: Int?

    @IBOutlet weak var imageSlideshowCarImages: ImageSlideshow!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var tableViewStages: UITableView!
    @IBOutlet weak var lcTableViewStagesHeight: NSLayoutConstraint!
    @IBOutlet weak var labelImageSource: UILabel!
    private var isGalleryVisible: Bool = false

    private static let viewTagCellDescriptionLabel = 1337
    private static let viewTagCellKPIValues = 1338

    @IBOutlet weak var bannerView: GADBannerView!

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if isGalleryVisible {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

    override var prefersStatusBarHidden: Bool {
        return isGalleryVisible
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if ProcessInfo.processInfo.arguments.contains("TAKING_SCREENSHOTS") {
            bannerView.isHidden = true
        }

        loadVideoInformation()
        loadSlideshowImage()

        navigationItem.rightBarButtonItem?.title = "compare".localized()
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "compare"

        DispatchQueue.main.async {
            self.expandSectionAt(0, animated: false)
        }

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerCarDetail()
        bannerView.rootViewController = self
        bannerView.load(AdMobService.sharedService.request())

        imageSlideshowCarImages.currentPageChanged = { [weak self] _ in
            self?.updateSourceForSelectedSlideshowImage()
        }

        // add gradient view in image slider
        let gradientView = UIView()
        gradientView.backgroundColor = UIColor.clear
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        imageSlideshowCarImages.insertSubview(gradientView,
                                              belowSubview: imageSlideshowCarImages.pageControl)
        gradientView.leftAnchor.constraint(equalTo: imageSlideshowCarImages.leftAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: imageSlideshowCarImages.topAnchor).isActive = true
        gradientView.rightAnchor.constraint(equalTo: imageSlideshowCarImages.rightAnchor).isActive = true
        gradientView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        gradientView.layoutIfNeeded()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor(white: 0, alpha: 0.5).cgColor,
            UIColor(white: 0, alpha: 0.3).cgColor,
            UIColor(white: 0, alpha: 0.0).cgColor
        ]
        gradientView.layer.addSublayer(gradientLayer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureTapImageSlideshowCarImages))
        imageSlideshowCarImages.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUpdateAllRelationsForCarModelNotification),
                                               name: SyncService.didUpdateAllRelationsForCarModelNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUpdateStagesVideosNotification),
                                               name: SyncService.didUpdateStagesVideosNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fixInterfaceOrientationIfNeeded),
                                               name: UIWindow.didBecomeHiddenNotification,
                                               object: view.window)

        DispatchQueue.main.async { [weak self] in
            self?.updateTableViewHeightConstraint()
        }
    }

    @objc private func didUpdateAllRelationsForCarModelNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let id = notification.userInfo?["id"] as? Int else { return }
            guard let carModel = StorageService.shared.carModelWithID(id) else { return }
            guard let newCarItem = CarService.carItemFromCarModel(carModel) else { return }

            self.carItem = newCarItem
            self.loadVideoInformation()
            self.loadSlideshowImage()
        }
    }

    @objc private func didUpdateStagesVideosNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let carModelID = self.carItem?.carModelId else { return }
            guard let carModel = StorageService.shared.carModelWithID(carModelID) else { return }
            guard let newCarItem = CarService.carItemFromCarModel(carModel) else { return }

            self.carItem = newCarItem
            self.loadVideoInformation()
            self.loadSlideshowImage()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self,
                                                  name: UIWindow.didBecomeHiddenNotification,
                                                  object: view.window)

        NotificationCenter.default.removeObserver(self,
                                                  name: SyncService.didUpdateAllRelationsForCarModelNotification,
                                                  object: nil)

        NotificationCenter.default.removeObserver(self,
                                                  name: SyncService.didUpdateStagesVideosNotification,
                                                  object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        let isOnStack = navigationController?.viewControllers.contains(self) ?? false
        if !isOnStack {
            bannerView.removeFromSuperview()
            carItem = nil
            imageSlideshowCarImages.removeFromSuperview()
        }
    }

    // MARK: - Actions

    @IBAction func actionCompare(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "compare", sender: self)
    }

    // MARK: - Slider Images

    private func loadSlideshowImage() {
        guard let images = carItem?.images else { return }

        imageSlideshowCarImages.contentScaleMode = .scaleAspectFill
        imageSlideshowCarImages.slideshowInterval = 10

        if images.count > 0 {
            imageSlideshowCarImages.setImageInputs(images.map { CarImageInputSource(carImage: $0) })
        } else {
            imageSlideshowCarImages.setImageInputs([ImageSource(image: #imageLiteral(resourceName: "img_no_image"))])
            self.updateSourceForSelectedSlideshowImage()
        }

        if let mainIndex = images.firstIndex(where: { $0.isMainImage }) {
            imageSlideshowCarImages.setCurrentPage(mainIndex, animated: false)
            self.updateSourceForSelectedSlideshowImage()
        }
    }

    private func updateSourceForSelectedSlideshowImage() {
        let selectedSlideshowImageIndex = imageSlideshowCarImages.currentPage
        guard let selectedImage = carItem?.images[safe: selectedSlideshowImageIndex],
            let copyrightInformation = selectedImage.copyrightInformation
        else {
            labelImageSource.text = ""
            return
        }

        labelImageSource.text = "\("image_source".localized()): \(copyrightInformation)"
    }

    @objc private func gestureTapImageSlideshowCarImages(gesture: UITapGestureRecognizer) {
        performSegue(withIdentifier: "showImageGallery", sender: self)
    }

    private func loadVideoInformation() {
        guard let carItem = carItem else { return }

        title = carItem.model
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title
        labelTitle.text = "\(carItem.manufacturer) \(carItem.model)"

        tableViewStages.reloadData()
    }

    fileprivate func expandSectionAt(_ sectionIndex: Int, animated: Bool = true) {
        if expandedSectionIndex == sectionIndex {
            expandedSectionIndex = nil
        } else {
            if isExpandableSectionAt(sectionIndex) {
                expandedSectionIndex = sectionIndex
            } else {
                expandedSectionIndex = nil
            }
        }

        let animationBlock = {
            self.tableViewStages.beginUpdates()
            self.tableViewStages.endUpdates()

            self.updateTableViewHeightConstraint()
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                animationBlock()
            }) { _ in }
        } else {
            animationBlock()
        }

    }

    fileprivate func isExpandableSectionAt(_ sectionIndex: Int) -> Bool {
        guard let sectionModel = carItem?.stages[safe: sectionIndex] else { return false }

        if sectionModel.description.count > 0 {
            return true
        }

        if sectionModel.youtubeIDs.count > 0 {
            return true
        }

        return false
    }

    fileprivate func showYoutubeVideoForSectionAt(_ sectionIndex: Int) {
        guard let sectionModel = carItem?.stages[sectionIndex] else { return }
        let videos = sectionModel.youtubeIDs.compactMap({ StorageService.shared.youtubeVideoWithVideoID($0) })

        if videos.count == 1, let video = videos.first {
            self.performSegue(withIdentifier: "showYoutubeVideoDetail", sender: video)
        } else {
            let alertController = UIAlertController(title: "car_detail_video_selection_alert_title".localized(),
                                                    message: "car_detail_video_selection_alert_message".localized(),
                                                    preferredStyle: .actionSheet)
            for video in videos {
                alertController.addAction(UIAlertAction(title: video.shortTitle(), style: .default, handler: { _ in
                    self.performSegue(withIdentifier: "showYoutubeVideoDetail", sender: video)
                }))
            }
            alertController.addAction(UIAlertAction(title: "car_detail_video_selection_alert_button_cancel".localized(),
                                                    style: .cancel,
                                                    handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

    private func updateTableViewHeightConstraint() {
        self.lcTableViewStagesHeight.constant = self.tableViewStages.contentSize.height
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showYoutubeVideoDetail",
            let youtubeDetailVC = segue.destination as? JPVideoDetailVC,
            let video = sender as? YoutubeVideoModel
        {
            youtubeDetailVC.video = video
        }

        if segue.identifier == "showImageGallery", let gallerySegue = segue as? GallerySegue {
            let initialFrame = view.convert(imageSlideshowCarImages.frame, from: imageSlideshowCarImages)
            isGalleryVisible = true
            gallerySegue.initialFrame = initialFrame
            gallerySegue.initialImageSlideshow = imageSlideshowCarImages
        }

        if segue.identifier == "compare", let compareVC = segue.destination as? CompareVC {
            compareVC.leftCarItem = carItem
        }
    }

}


extension JPCarDetailVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let carItem = carItem else { return 0 }
        return carItem.stages.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionModel = carItem?.stages[section], let timings = sectionModel.timings else { return 0 }
        return timings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let sectionModel = carItem?.stages[indexPath.section],
            let timing = sectionModel.timings?[indexPath.row]
        else {
            abort()
        }

        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarStageTimingCell",
                                                 for: indexPath) as! CarStageTimingCell
        // swiftlint:enable force_cast

        cell.carStageTiming = timing
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionModel = carItem?.stages[section] else { return nil }
        return sectionModel.title
    }

}


extension JPCarDetailVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let normalHeight: CGFloat = 25.0

//        if expandedSectionIndex == section {
            var expandedHeight = normalHeight

            // description height
            if let headerView = tableViewHeaderViewFor(section: section, title: "DummyHeader", height: normalHeight) {
                if let descriptionLabel = headerView.viewWithTag(JPCarDetailVC.viewTagCellDescriptionLabel) as? UILabel {
                    let descriptionLabelWidth = UIScreen.main.bounds.size.width - 16 - 100
                    let size = descriptionLabel.sizeThatFits(CGSize(width: descriptionLabelWidth,
                                                                    height: CGFloat.greatestFiniteMagnitude))
                    expandedHeight += size.height
                    expandedHeight += 16 // spacer
                }

                if let stackViewKPIValues = headerView.viewWithTag(JPCarDetailVC.viewTagCellKPIValues) as? UIStackView {
                    expandedHeight += 50
                }
            }

            // youtube button
            if let sectionModel = carItem?.stages[section], sectionModel.youtubeIDs.count > 0 {
                expandedHeight = max(expandedHeight, 60)
            }

            return expandedHeight
//        } else {
//            return normalHeight
//        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) else { return nil }
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        return tableViewHeaderViewFor(section: section, title: title, height: height)
    }

    private func tableViewHeaderViewFor(section: Int, title: String, height: CGFloat) -> UIView? {
        guard let sectionModel = carItem?.stages[section] else { return nil }
        
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: height)))
        view.tag = section
        view.backgroundColor = UIColor.jpLightGrayColor
        view.clipsToBounds = true

        // row title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Montserrat-Medium", size: 12)
        titleLabel.textColor = UIColor.jpDarkGrayColor
        titleLabel.text = title
        view.addSubview(titleLabel)
        view.addConstraints([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        // add tap gesture
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(JPCarDetailVC.gestureSectionTap(gesture:)))
//        tapGesture.numberOfTapsRequired = 1
//        view.addGestureRecognizer(tapGesture)

        // add description label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont(name: "Montserrat-Light", size: 10)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = UIColor.jpDarkGrayColor
        descriptionLabel.text = sectionModel.displayDescription()
        descriptionLabel.backgroundColor = UIColor.clear
        descriptionLabel.tag = JPCarDetailVC.viewTagCellDescriptionLabel

        view.addSubview(descriptionLabel)
        view.addConstraints([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: -100)
        ])

        var kpiValues: [String] = []
        if let displayPS = sectionModel.displayStringForPS() {
            kpiValues.append(displayPS)
        }
        if let displayNM = sectionModel.displayStringForNM() {
            kpiValues.append(displayNM)
        }
        if kpiValues.count > 0 {
            let kpiValuesStackView = UIStackView()
            kpiValuesStackView.translatesAutoresizingMaskIntoConstraints = false
            kpiValuesStackView.axis = .horizontal
            kpiValuesStackView.tag = JPCarDetailVC.viewTagCellKPIValues
            kpiValuesStackView.alignment = .fill
            kpiValuesStackView.distribution = .fillProportionally
            kpiValuesStackView.spacing = 8

            view.addSubview(kpiValuesStackView)
            view.addConstraints([
                kpiValuesStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
                kpiValuesStackView.leftAnchor.constraint(equalTo: descriptionLabel.leftAnchor),
                kpiValuesStackView.rightAnchor.constraint(equalTo: descriptionLabel.rightAnchor),
                kpiValuesStackView.heightAnchor.constraint(equalToConstant: 40)
            ])

            for kpiValue in kpiValues {
                let kpiLabel = UILabel()
                kpiLabel.translatesAutoresizingMaskIntoConstraints = false
                kpiLabel.font = UIFont(name: "Montserrat-Light", size: 16)
                kpiLabel.numberOfLines = 1
                kpiLabel.textColor = UIColor.jpDarkGrayColor
                kpiLabel.text = kpiValue
                kpiLabel.backgroundColor = UIColor.clear
                kpiLabel.setContentHuggingPriority(.required, for: .horizontal)

                kpiValuesStackView.addArrangedSubview(kpiLabel)
            }

            let stretchingView = UIView()
            stretchingView.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
            stretchingView.backgroundColor = UIColor.clear
            stretchingView.translatesAutoresizingMaskIntoConstraints = false
            kpiValuesStackView.addArrangedSubview(stretchingView)
        }

        // add go to youtube video button
        if sectionModel.youtubeIDs.count > 0 {
            let youtubeVideoButton = UIButton()
            youtubeVideoButton.translatesAutoresizingMaskIntoConstraints = false
            youtubeVideoButton.setImage(#imageLiteral(resourceName: "icon_youtube").withRenderingMode(.alwaysTemplate), for: .normal)
            youtubeVideoButton.tag = section
            youtubeVideoButton.addTarget(self,
                                         action: #selector(JPCarDetailVC.actionSectionYoutubeTap(sender:)),
                                         for: .touchUpInside)

            view.addSubview(youtubeVideoButton)
            view.addConstraints([
                youtubeVideoButton.leftAnchor.constraint(equalTo: descriptionLabel.rightAnchor),
                youtubeVideoButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
                youtubeVideoButton.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
            youtubeVideoButton.addConstraint(youtubeVideoButton.heightAnchor.constraint(equalToConstant: 44))
        }

        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        expandSectionAt(indexPath.section)
//    }
//
//    @objc func gestureSectionTap(gesture: UITapGestureRecognizer) {
//        guard let sectionView = gesture.view else { return }
//        expandSectionAt(sectionView.tag)
//    }

    @objc func actionSectionYoutubeTap(sender: UIButton) {
        showYoutubeVideoForSectionAt(sender.tag)
    }

}

extension JPCarDetailVC: GalleryVCDelegate {

    func galleryVCWillDismiss(_ galleryVC: GalleryVC) {
        isGalleryVisible = false
        imageSlideshowCarImages.setCurrentPage(galleryVC.imageSlideshowGallery.currentPage, animated: false)
        setNeedsStatusBarAppearanceUpdate()
        fixInterfaceOrientationIfNeeded()
    }

}
