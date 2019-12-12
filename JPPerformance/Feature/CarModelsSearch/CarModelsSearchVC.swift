//
//  CarModelsSearchVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 06.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit


class CarModelsSearchVC: UIViewController {

    @IBOutlet var tableView: UITableView!

    private let http = UIApplication.http

    private let viewModel = ViewModel(http: UIApplication.http)

    var initialSearchText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "search-title".localized()

        tableView.sectionIndexColor = .systemGray
        tableView.sectionIndexBackgroundColor = .clear

        let searchController = UISearchController()
        searchController.searchBar.placeholder = "search-placeholder".localized()
        searchController.searchBar.text = initialSearchText
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true

        viewModel.delegate = self
    }

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

}

// MARK: - UITableViewDataSource

extension CarModelsSearchVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "PerformanceRowTableViewCell",
                                                 for: indexPath) as! PerformanceRowTableViewCell
        // swiftlint:enable force_cast

        let carModel = viewModel.sections[indexPath.section].models[indexPath.row]
        cell.carModel = carModel
        cell.carStage = nil
        cell.labelPerformanceValue.text = ""

        return cell
    }

}

// MARK: - UITableViewDelegate

extension CarModelsSearchVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].manufacturer.name
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let carModel = viewModel.sections[indexPath.section].models[indexPath.row]
        performSegue(withIdentifier: "showCarModelDetail", sender: carModel)
    }

    static let sectionIndexTitles: [String] = [
        "A", "B", "C", "D", "E", "F", "G", "H",
        "I", "J", "K", "L", "M", "N", "O", "P",
        "Q", "R", "S", "T", "U", "V", "W", "X",
        "Y", "Z"
    ]

    func sectionForSectionIndexTitle(at index: Int) -> Int? {
        let sectionTitle = CarModelsSearchVC.sectionIndexTitles[index]
        return viewModel.sections.firstIndex(where: { $0.manufacturer.name.uppercased().hasPrefix(sectionTitle) })
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return CarModelsSearchVC.sectionIndexTitles
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

extension CarModelsSearchVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(text: searchText)
    }

}

extension CarModelsSearchVC: CarModelsSearchVCDelegate {

    func didUpdateSearchResults() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}

// MARK: - View Model

protocol CarModelsSearchVCDelegate: class {

    func didUpdateSearchResults()

}

private extension CarModelsSearchVC {

    class ViewModel {

        weak var delegate: CarModelsSearchVCDelegate?
        private let http: HTTP

        private var manufacturers: [JPFanAppClient.ManufacturerModel] = []
        private var carModels: [JPFanAppClient.CarModel] = []

        private var searchText: String?

        private(set) var sections: [Section] = []

        init(http: HTTP) {
            self.http = http

            http.getManufacturers().and(http.getCarModels()).whenSuccess { tuple in
                self.manufacturers = tuple.0
                self.carModels = tuple.1

                self.performFilter()
            }
        }

        func search(text: String) {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            searchText = trimmedText.count > 0 ? trimmedText : nil
            performFilter()
        }

        private func performFilter() {
            let lowerSearchText = searchText?.lowercased()
            print("search \(searchText)")
            sections = manufacturers
                .sorted(by: { $0.name < $1.name })
                .map
            { manufacturer in
                return Section(manufacturer: manufacturer,
                               models: carModels
                                .filter({ $0.manufacturerID == manufacturer.id })
                                .sorted(by: { $0.name < $1.name }
                ))
            }.filter { section in
                guard let lowerSearchText = lowerSearchText else { return true }
                return section.manufacturer.name.lowercased().contains(lowerSearchText) || section.models.contains(where: { carModel in
                    carModel.name.lowercased().contains(lowerSearchText)
                })
            }
            delegate?.didUpdateSearchResults()
        }

    }

}

private extension CarModelsSearchVC.ViewModel {

    struct Section {

        let manufacturer: JPFanAppClient.ManufacturerModel
        let models: [JPFanAppClient.CarModel]

    }

}
