//
//  JPCarsVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 17.09.17.
//  Copyright © 2017 Christoph Pageler. All rights reserved.
//


import UIKit
import GoogleMobileAds


class JPCarsVC: JPBaseViewController {

    let viewModel = ViewModel()
    @IBOutlet weak var tableViewCars: UITableView!
    @IBOutlet weak var searchBarCars: UISearchBar!
    var refreshControlTableView = UIRefreshControl()
    @IBOutlet weak var viewLoadingError: UIView!

    private var hasBanner: Bool = false {
        didSet {
            print("set has banner in CarsVC \(hasBanner)")
//            lcBannerViewHeight?.constant = 0
            lcBannerViewHeight?.constant = hasBanner ? 50 : 0

            if ProcessInfo.processInfo.arguments.contains("TAKING_SCREENSHOTS") {
                lcBannerViewHeight?.constant = 0
            }
        }
    }
    @IBOutlet var bannerView: GADBannerView?
    @IBOutlet var lcBannerViewHeight: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "cars".localized()
        navigationItem.title = title
        navigationItem.backBarButtonItem?.title = title

        bannerView?.adSize = kGADAdSizeSmartBannerPortrait
        bannerView?.adUnitID = AdMobService.sharedService.adUnitIDForBottomBannerCarList()
        bannerView?.rootViewController = self
        bannerView?.delegate = self
        bannerView?.load(AdMobService.sharedService.request())

        if let searchBarTextField = searchBarCars.value(forKey: "searchField") as? UITextField {
            searchBarTextField.font = UIFont(name: "Montserrat", size: 14)
        }
        searchBarCars.alpha = 0
        viewLoadingError.alpha = 0
        
        tableViewCars.rowHeight = UITableView.automaticDimension
        tableViewCars.estimatedRowHeight = 103

        tableViewCars.sectionIndexColor = .jpDarkGrayColor
        tableViewCars.sectionIndexBackgroundColor = .clear

        refreshControlTableView.addTarget(self,
                                          action: #selector(JPCarsVC.didPerformRefreshControl),
                                          for: .valueChanged)
        tableViewCars.addSubview(refreshControlTableView)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUpdateTimingsNotification),
                                               name: SyncService.didUpdateTimingsNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUpdateStagesVideosNotification),
                                               name: SyncService.didUpdateStagesVideosNotification,
                                               object: nil)

        fetchCarData(scrollToTop: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedIndexPath = tableViewCars.indexPathForSelectedRow {
            tableViewCars.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if viewModel.carData?.cars.count == 0 {
            fetchCarData(scrollToTop: true)
        }
    }

    @objc private func didUpdateTimingsNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.fetchCarData(forceReload: false, scrollToTop: false)
        }
    }

    @objc private func didUpdateStagesVideosNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.fetchCarData(forceReload: false, scrollToTop: false)
        }
    }

    @objc func didPerformRefreshControl() {
        refreshControlTableView.beginRefreshing()
        fetchCarData(forceReload: true, scrollToTop: true)
    }

    func fetchCarData(forceReload: Bool = false,
                      scrollToTop: Bool = false,
                      completion: (() -> Void)? = nil) {
        if forceReload {
            SyncService.shared.synchronizeCarInformation {
                self.fetchCarData(forceReload: false,
                                  scrollToTop: scrollToTop)
            }
            return
        }
        CarService.sharedInstance.fetchData { carData in
            self.viewModel.carData = carData
            self.viewModel.updateSectionsFromCarData()
            self.tableViewCars.reloadData()

            if scrollToTop && carData?.cars.count ?? 0 > 0 {
                self.tableViewCars.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            self.searchBarCars.alpha = 1
            self.refreshControlTableView.endRefreshing()

            self.updateLoadingError()
            completion?()
        }
    }

    func updateLoadingError() {
        var hasLoadingError = viewModel.carData?.cars.count ?? 0 == 0
        if SyncService.shared.isSyncing && hasLoadingError {
            hasLoadingError = false
            refreshControlTableView.beginRefreshing()
            var contentOffset = tableViewCars.contentOffset
            contentOffset.y -= refreshControlTableView.frame.size.height
            tableViewCars.setContentOffset(contentOffset, animated: true)
        }

        viewLoadingError.alpha = hasLoadingError ? 1 : 0
        searchBarCars.alpha = hasLoadingError ? 0 : 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
            let detailVC = segue.destination as? JPCarDetailVC,
            let carItem = sender as? JPCarItem
        {
            detailVC.carItem = carItem
        }
    }

    func didSelectCarItem(_ carItem: JPCarItem) {
        performSegue(withIdentifier: "showDetail", sender: carItem)
    }

    func selectCarModel(_ carModel: CarModel, reloadData: Bool) {
        if reloadData {
            fetchCarData {
                self.selectCarModel(carModel, reloadData: false)
            }
        } else {
            sectionLoop: for section in viewModel.filteredSections() {
                for row in section.rows {
                    if row.carItem.carModelId == carModel.id {
                        didSelectCarItem(row.carItem)
                        break sectionLoop
                    }
                }
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension JPCarsVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.filteredSections().count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionModel = viewModel.filteredSections()[section]
        return sectionModel.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionModel = viewModel.filteredSections()[section]
        return sectionModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = viewModel.filteredSections()[indexPath.section]
        let rowModel = sectionModel.rows[indexPath.row]

        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarTableViewCell",
                                                 for: indexPath) as! CarTableViewCell
        // swiftlint:enable force_cast
        cell.carItem = rowModel.carItem
        cell.accessibilityIdentifier = "carItemCell_\(indexPath.section)_\(indexPath.row)"

        return cell
    }
}

// MARK: - UITableViewDelegate

extension JPCarsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) else { return nil }
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: height)))

        view.backgroundColor = UIColor.jpLightGrayColor

        // row title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Montserrat-Semibold", size: 14)
        titleLabel.textColor = UIColor.jpDarkGrayColor
        titleLabel.text = title
        view.addSubview(titleLabel)
        view.addConstraints([
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 30)
        ])

        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let height = self.tableView(tableView, heightForFooterInSection: section)
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: height)))
        view.backgroundColor = UIColor.clear
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionModel = viewModel.filteredSections()[indexPath.section]
        let rowModel = sectionModel.rows[indexPath.row]

        didSelectCarItem(rowModel.carItem)
    }

    static let sectionIndexTitles: [String] = [
        "A", "B", "C", "D", "E", "F", "G", "H",
        "I", "J", "K", "L", "M", "N", "O", "P",
        "Q", "R", "S", "T", "U", "V", "W", "X",
        "Y", "Z"
    ]

    func sectionForSectionIndexTitle(at index: Int) -> Int? {
        let sectionTitle = JPCarsVC.sectionIndexTitles[index]
        return viewModel.filteredSections().index(where: { $0.title.uppercased().hasPrefix(sectionTitle.uppercased()) })
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return JPCarsVC.sectionIndexTitles
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let realIndex = sectionForSectionIndexTitle(at: index) {
            return realIndex
        }

        // find index before
        var indexBefore = index - 1
        while(indexBefore >= 0) {
            if let sectionBefore = sectionForSectionIndexTitle(at: indexBefore) {
                return sectionBefore
            }
            indexBefore -= 1
        }

        return 0
    }

}

extension JPCarsVC: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBarCars.isFirstResponder && scrollView.contentOffset.y > 10 {
            searchBarCars.resignFirstResponder()
        }
    }

}

// MARK: - UISearchBarDelegate

extension JPCarsVC: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        tableViewCars.reloadData()
    }

}

// MARK: - View Model

extension JPCarsVC {

    class ViewModel {

        class Section {

            class Row {

                let carItem: JPCarItem

                init(carItem: JPCarItem) {
                    self.carItem = carItem
                }

            }

            let title: String
            let rows: [Row]

            init(title: String, rows: [Row]) {
                self.title = title
                self.rows = rows
            }

        }

        var carData: JPCarData?
        var sections = [Section]()

        var searchText: String? = nil {
            didSet {
                if searchText?.count == 0 {
                    searchText = nil
                }
            }
        }

        func filteredSections() -> [Section] {
            guard let searchText = searchText else {
                return sections
            }

            var filtered = [Section]()
            for section in sections {
                if section.title.uppercased().contains(searchText.uppercased()) {
                    filtered.append(section)
                    continue
                }

                var filteredRows = [Section.Row]()
                for row in section.rows {
                    let manufacturerContains = row.carItem.manufacturer.uppercased().contains(searchText.uppercased())
                    let modelContains = row.carItem.model.uppercased().contains(searchText.uppercased())
                    let stageContains = row.carItem.stages.filter({
                        $0.description.uppercased().contains(searchText.uppercased())
                            || $0.title.uppercased().contains(searchText.uppercased())
                    }).count > 0

                    if manufacturerContains || modelContains || stageContains {
                        filteredRows.append(row)
                    }
                }
                if filteredRows.count > 0 {
                    filtered.append(Section(title: section.title, rows: filteredRows))
                }
            }

            return filtered
        }

        func updateSectionsFromCarData() {
            guard let carData = carData else {
                sections = []
                return
            }

            // group sections
            var groupedCarData = [String: [JPCarItem]]()
            for carItem in carData.cars {
                let groupKey = carItem.groupKey()
                var carGroup = groupedCarData[groupKey] ?? []
                carGroup.append(carItem)
                groupedCarData[groupKey] = carGroup
            }

            // map sections
            sections = groupedCarData.compactMap { Section(title: $0.key, rows: $0.value.compactMap { JPCarsVC.ViewModel.Section.Row(carItem: $0) } ) }

            // keep manufacturers for section sort
            let manufacturers = carData.cars.map { $0.groupKey() }.removeDuplicates().sorted()

            // re-order sections
            sections.sort { (section1, section2) -> Bool in
                guard
                    let indexSection1 = manufacturers.index(of: section1.title),
                    let indexSection2 = manufacturers.index(of: section2.title)
                    else {
                        return true
                }

                return indexSection1 < indexSection2
            }
        }

    }

}


extension JPCarsVC: GADBannerViewDelegate {

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        hasBanner = true
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hasBanner = false
    }

}
