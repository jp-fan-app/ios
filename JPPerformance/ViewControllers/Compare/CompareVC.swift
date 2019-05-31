//
//  CompareVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 25.06.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import UIKit
import GoogleMobileAds
import Alamofire


class CompareVC: JPBaseViewController {

    @IBOutlet weak var activityIndicatorViewLeftCarImage: UIActivityIndicatorView!
    @IBOutlet weak var imageViewLeftCarImage: UIImageView!
    var leftCarItem: JPCarItem? {
        didSet {
            loadLeftCarItem()
        }
    }
    @IBOutlet weak var labelLeftCarManufacturer: UILabel!
    @IBOutlet weak var labelLeftCarModel: UILabel!
    @IBOutlet weak var tableViewLeftCar: UITableView!


    @IBOutlet weak var activityIndicatorViewRightCarImage: UIActivityIndicatorView!
    @IBOutlet weak var imageViewRightCarImage: UIImageView!
    var rightCarItem: JPCarItem? {
        didSet {
            loadRightCarItem()
        }
    }
    @IBOutlet weak var labelRightCarManufacturer: UILabel!
    @IBOutlet weak var labelRightCarModel: UILabel!
    @IBOutlet weak var viewRightCarInformation: UIView!
    @IBOutlet weak var tableViewRightCar: UITableView!


    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var buttonSelect: UIButton!

    let viewModel = ViewModel()


    override func viewDidLoad() {
        super.viewDidLoad()

        if ProcessInfo.processInfo.arguments.contains("TAKING_SCREENSHOTS") {
            bannerView.isHidden = true
        }

        title = "compare".localized()
        navigationItem.title = title
        buttonSelect.setTitle("select".localized(), for: .normal)
        buttonSelect.accessibilityIdentifier = "select"
        navigationItem.backBarButtonItem?.title = title

        bannerView.adSize = kGADAdSizeSmartBannerPortrait
        bannerView.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerCarCompare()
        bannerView.rootViewController = self
        bannerView.load(AdMobService.sharedService.request())

        loadLeftCarItem()
        loadRightCarItem()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCarSelection", let carSelectionVC = segue.destination as? CarSelectionVC {
            carSelectionVC.delegate = self
        }
    }

    private func loadLeftCarItem() {
        guard let carItem = leftCarItem else { return }
        guard isViewLoaded else { return }

        viewModel.leftCarItem = carItem
        reloadTableViews()

        loadCarImage(carItem: carItem,
                     imageViewCar: imageViewLeftCarImage,
                     activityIndicatorView: activityIndicatorViewLeftCarImage,
                     labelManufacturer: labelLeftCarManufacturer,
                     labelModel: labelLeftCarModel)
    }

    private func loadRightCarItem() {
        let hasCarItem = rightCarItem != nil
        viewRightCarInformation.alpha = hasCarItem ? 1 : 0

        viewModel.rightCarItem = rightCarItem
        reloadTableViews()

        buttonSelect.tintColor = hasCarItem ? .clear : view.tintColor

        guard let carItem = rightCarItem else { return }
        guard isViewLoaded else { return }

        loadCarImage(carItem: carItem,
                     imageViewCar: imageViewRightCarImage,
                     activityIndicatorView: activityIndicatorViewRightCarImage,
                     labelManufacturer: labelRightCarManufacturer,
                     labelModel: labelRightCarModel)
    }

    func loadCarImage(carItem: JPCarItem,
                      imageViewCar: UIImageView,
                      activityIndicatorView: UIActivityIndicatorView,
                      labelManufacturer: UILabel,
                      labelModel: UILabel) {
        labelManufacturer.text = carItem.manufacturer
        labelModel.text = carItem.model

        guard let mainImage = carItem.mainImage() else {
            imageViewCar.image = #imageLiteral(resourceName: "img_no_image")
            return
        }

        // reset or check cache
        if let cachedImage = ImageCache.sharedInstance.cachedImageFor(mainImage.id, type: "image") {
            imageViewCar.image = cachedImage
        } else {
            imageViewCar.image = nil
            activityIndicatorView.startAnimating()

            HTTPService.shared.carImageFile(id: mainImage.id) { _, image in
                imageViewCar.image = image
                activityIndicatorView.stopAnimating()
                if let image = image {
                    ImageCache.sharedInstance.cacheImage(image, forId: mainImage.id, type: "image")
                }
            }
        }
    }

    func reloadTableViews() {
        tableViewLeftCar.reloadData()
        tableViewRightCar.reloadData()
    }

    @IBAction func actionSelectCar(_ sender: UIButton) {
        performSegue(withIdentifier: "showCarSelection", sender: nil)
    }

}


extension CompareVC: CarSelectionVCDelegate {

    func carSelectionVC(_ carSelectionVC: CarSelectionVC,
                        didSelectCarItem carItem: JPCarItem) {
        rightCarItem = carItem
    }

}


extension CompareVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.compareSections.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.compareSections[section]
        return section.timingRows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = viewModel.compareSections[section]
        return section.compareRange
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompareStageTableViewCell",
                                                 for: indexPath) as! CompareStageTableViewCell
        // swiftlint:enable force_cast

        let section = viewModel.compareSections[indexPath.section]
        let timingRow = section.timingRows[indexPath.row]

        let stage = tableView == tableViewLeftCar ? timingRow.stageLeftCar : timingRow.stageRightCar
        cell.labelStageName.text = stage?.title
        cell.labelStageTiming.tagBackgroundColor = UIColor.jpDarkGrayColor.withAlphaComponent(0.15)
        if stage?.isBestStageForRange ?? false {
            cell.labelStageTiming.tagBackgroundColor = UIColor.green.withAlphaComponent(0.5)
        }
        cell.labelStageTiming.textColor = UIColor.jpDarkGrayColor
        if let bestTiming = stage?.bestTiming {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.minimumFractionDigits = 3
            nf.maximumFractionDigits = 3

            if section.compareRange == "LaSiSe" {
                let seconds = bestTiming

                let minutesInt = Int(floor(seconds / 60.0))
                let secondsInt = Int(seconds - Double(minutesInt * 60))
                let fractionInt = Int((Double(seconds) - floor(seconds)) * 10)

                let minutesString = minutesInt < 10 ? "0\(minutesInt)" : "\(minutesInt)"
                let secondsString = secondsInt < 10 ? "0\(secondsInt)" : "\(secondsInt)"

                cell.labelStageTiming.text = "\(minutesString):\(secondsString),\(fractionInt)"
            } else {
                cell.labelStageTiming.text = nf.string(from: NSNumber(value: bestTiming))
            }
            cell.labelStageTiming.isHidden = false
        } else {
            cell.labelStageTiming.isHidden = true
        }

        return cell
    }

}

extension CompareVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) else { return nil }
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        return tableViewHeaderViewFor(section: section, title: title, height: height)
    }

    private func tableViewHeaderViewFor(section: Int, title: String, height: CGFloat) -> UIView? {
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
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 4)
        ])

        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableViewLeftCar {
            tableViewRightCar.contentOffset = scrollView.contentOffset
        } else {
            tableViewLeftCar.contentOffset = scrollView.contentOffset
        }
    }

}


extension CompareVC {

    class ViewModel {

        var leftCarItem: JPCarItem? {
            didSet {
                updateSections()
            }
        }
        var rightCarItem: JPCarItem? {
            didSet {
                updateSections()
            }
        }

        var compareSections: [CompareSection] = []

        private func updateSections() {
            // collect compare ranges
            let allRanges = Array(Set([leftCarItem, rightCarItem]
                .compactMap({ $0 })
                .compactMap({ $0.stages })
                .flatMap({ $0 })
                .compactMap({ $0.timings })
                .flatMap({ $0 })
                .compactMap({ $0.range })))

            compareSections.removeAll()
            for range in allRanges {
                let section = CompareSection()
                section.compareRange = range

                let leftCarStages = leftCarItem?.stages(inRange: range) ?? []
                let rightCarStages = rightCarItem?.stages(inRange: range) ?? []

                let leftCarBestTimingInRange = leftCarItem?.bestStage(inRange: range)?.bestTiming(inRange: range)?.bestSecond()
                let rightCarBestTimingInRange = rightCarItem?.bestStage(inRange: range)?.bestTiming(inRange: range)?.bestSecond()

                for i in 0..<max(leftCarStages.count, rightCarStages.count) {
                    let timingRow = CompareSection.TimingRow()

                    if let leftCarStage = leftCarStages[safe: i] {
                        timingRow.stageLeftCar = CompareSection.TimingRow.Stage()
                        timingRow.stageLeftCar?.title = leftCarStage.title
                        timingRow.stageLeftCar?.bestTiming = leftCarStage.bestTiming(inRange: range)?.bestSecond()
                        timingRow.stageLeftCar?.isBestStageForRange = timingRow.stageLeftCar?.bestTiming == leftCarBestTimingInRange && timingRow.stageLeftCar?.bestTiming ?? 999.0 < rightCarBestTimingInRange ?? 999.0
                    }
                    if let rightCarStage = rightCarStages[safe: i] {
                        timingRow.stageRightCar = CompareSection.TimingRow.Stage()
                        timingRow.stageRightCar?.title = rightCarStage.title
                        timingRow.stageRightCar?.bestTiming = rightCarStage.bestTiming(inRange: range)?.bestSecond()
                        timingRow.stageRightCar?.isBestStageForRange = timingRow.stageRightCar?.bestTiming == rightCarBestTimingInRange && timingRow.stageRightCar?.bestTiming ?? 999.0 < leftCarBestTimingInRange ?? 999.0
                    }

                    section.timingRows.append(timingRow)
                }

                compareSections.append(section)
            }

        }

        class CompareSection {

            var compareRange: String = ""
            var timingRows: [TimingRow]

            init() {
                self.timingRows = []
            }

            class TimingRow {

                var stageLeftCar: Stage?
                var stageRightCar: Stage?

                class Stage {

                    var title: String?
                    var bestTiming: Double?
                    var isBestStageForRange: Bool?

                }

            }

        }

    }

}
