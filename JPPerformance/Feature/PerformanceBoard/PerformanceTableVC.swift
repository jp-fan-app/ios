//
//  PerformanceTableVC.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 07.12.19.
//  Copyright © 2019 Christoph Pageler. All rights reserved.
//


import UIKit
import JPFanAppClient
import NIO


protocol PerformanceTableVCDelegate: class {

    func performanceTableVC(_ performanceTableVC: PerformanceTableVC, didSelect carModel: JPFanAppClient.CarModel)

}


class PerformanceTableVC: UIViewController {

    var isLaSiSe: Bool = false
    private let viewModel = ViewModel()

    weak var delegate: PerformanceTableVCDelegate?

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "PerformanceBoardFilterHeaderView", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "PerformanceBoardFilterHeaderView")

        viewModel.delegate = self
        DispatchQueue.main.async {
            self.reloadData(index: self.viewModel.filterIndex)
        }
    }

    @IBAction func actionSegmentedControlPerformanceFilterValueChanged(_ sender: UISegmentedControl) {
        reloadData(index: sender.selectedSegmentIndex)
    }

    private func reloadData(index: Int) {
        var filter: ViewModel.PerformanceFilter
        switch index {
        case 0: filter = .range(str: "0-100")
        case 1: filter = .range(str: "100-200")
        case 2: filter = .ps
        case 3: filter = .nm
        default: return
        }
        if isLaSiSe {
            filter = .laSiSe
        }

        viewModel.update(with: filter, atIndex: index, limitToBestStageFromCar: true)
    }

}

// MARK: - UITableViewDataSource

extension PerformanceTableVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "PerformanceRowTableViewCell",
                                                 for: indexPath) as! PerformanceRowTableViewCell
        // swiftlint:enable force_cast

        let row = viewModel.rows[indexPath.row]
        cell.carModel = row.carModel
        cell.carStage = row.carStage
        cell.labelPerformanceValue.text = row.performanceValueDisplayString

        return cell
    }

}

// MARK: - UITableViewDelegate

extension PerformanceTableVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.rows[indexPath.row]
        delegate?.performanceTableVC(self, didSelect: row.carModel)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLaSiSe { return 0 }

        return 80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isLaSiSe { return nil }

        // swiftlint:disable force_cast
        let filterHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PerformanceBoardFilterHeaderView") as! PerformanceBoardFilterHeaderView
        // swiftlint:enable force_cast
        filterHeaderView.segmentedControlPerformanceFilter.selectedSegmentIndex = viewModel.filterIndex
        filterHeaderView.segmentedControlPerformanceFilter.removeTarget(self, action: nil, for: .allEvents)
        filterHeaderView.segmentedControlPerformanceFilter.addTarget(self,
                                                                     action: #selector(actionSegmentedControlPerformanceFilterValueChanged),
                                                                     for: .valueChanged)
        return filterHeaderView
    }

}

// MARK: - PerformanceBoardViewModelDelegate

extension PerformanceTableVC: PerformanceTableViewModelDelegate {

    func didUpdateBoard() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}

// MARK: - View Model

private protocol PerformanceTableViewModelDelegate: class {

    func didUpdateBoard()

}

private extension PerformanceTableVC {

    class ViewModel {

        weak var delegate: PerformanceTableViewModelDelegate?

        private(set) var filterIndex: Int = 0
        private(set) var currentPerformanceFilter: PerformanceFilter = .range(str: "0-100")

        var rows: [Row] = []

        let http = HTTP()

        enum PerformanceFilter: Equatable {

            case range(str: String)
            case ps
            case nm
            case laSiSe

        }

        func update(with filter: PerformanceFilter, atIndex index: Int, limitToBestStageFromCar: Bool) {
            filterIndex = index
            if currentPerformanceFilter != filter {
                rows = []
                delegate?.didUpdateBoard()
            }

            let future: EventLoopFuture<Void>

            switch filter {
            case .range(let str):
                future = updateWithRange(str)
            case .ps, .nm, .laSiSe:
                future = getWithStageValue(filter)
            }

            future.whenSuccess { _ in
                if limitToBestStageFromCar {
                    self.rows = self.rows.filter { row in
                        let sameCarModels = self.rows.filter({ $0.carModel.id == row.carModel.id })
                        if sameCarModels.count > 1 {
                            let bestCarStage = sameCarModels.first?.carStage
                            return row.carStage.id == bestCarStage?.id
                        }
                        return true
                    }
                }
                self.delegate?.didUpdateBoard()
            }
        }

        private func getWithStageValue(_ filter: PerformanceFilter) -> EventLoopFuture<Void> {
            func valueFromCarStage(_ carStage: JPFanAppClient.CarStage) -> Double? {
                switch filter {
                case .ps: return carStage.ps
                case .nm: return carStage.nm
                case .laSiSe: return carStage.lasiseInSeconds
                default: return nil
                }
            }

            return http.getCarModels().and(http.getCarStages()).map { tuple in
                let (carModels, allCarStages) = tuple

                let sortedCarStagesWithValue = allCarStages
                .filter({ valueFromCarStage($0) != nil })
                .sorted { (carStage1, carStage2) -> Bool in
                    if filter == .laSiSe {
                        return valueFromCarStage(carStage1) ?? 999999 < valueFromCarStage(carStage2) ?? 999999
                    } else {
                        return valueFromCarStage(carStage1) ?? 0 > valueFromCarStage(carStage2) ?? 0
                    }
                }
                typealias MappingType = (JPFanAppClient.CarModel, JPFanAppClient.CarStage)
                let mappedCarModelsWithStages = sortedCarStagesWithValue.compactMap { carStage -> MappingType? in
                    guard let matchingCarModel = carModels.first(where: { $0.id == carStage.carModelID }) else {
                        print("car model not found")
                        return nil
                    }
                    return (matchingCarModel, carStage)
                }

                self.rows = mappedCarModelsWithStages.map { tuple  in
                    let (carModel, carStage) = tuple
                    let displayString: String
                    switch filter {
                    case .ps:
                        displayString = NumberFormatter.psFormatter.string(from: valueFromCarStage(carStage)) ?? ""
                    case .nm:
                        displayString = NumberFormatter.nmFormatter.string(from: valueFromCarStage(carStage)) ?? ""
                    case .laSiSe:
                        displayString = carStage.laSiSeDisplayString() ?? ""
                    default: displayString = ""
                    }

                    return Row(carModel: carModel,
                               carStage: carStage,
                               performanceValueDisplayString: displayString)
                }
            }
        }

        private func updateWithRange(_ range: String) -> EventLoopFuture<Void> {
            return http.getCarModels()
                .and(http.getStageTimings())
                .and(http.getCarStages())
            .map { tuple in
                let ((carModels, allTimings), stages) = tuple

                let sortedTimingsForRange = allTimings
                    .filter({ $0.range == range && $0.bestSecond != nil })
                    .sorted(by: { $0.bestSecond ?? 99999 < $1.bestSecond ?? 99999 })
                typealias MappingType = (JPFanAppClient.CarModel, JPFanAppClient.CarStage, JPFanAppClient.StageTiming)
                let mappedTimingsWithStages = sortedTimingsForRange.compactMap { stageTiming -> MappingType? in
                    guard let matchingStage = stages.first(where: { $0.id == stageTiming.stageID }) else {
                        print("stage not found")
                        return nil
                    }
                    guard let matchingCarModel = carModels.first(where: { $0.id == matchingStage.carModelID }) else {
                        print("car model not found")
                        return nil
                    }
                    return (matchingCarModel, matchingStage, stageTiming)
                }

                self.rows = mappedTimingsWithStages.map { tuple  in
                    let (carModel, carStage, stageTiming) = tuple
                    return Row(carModel: carModel,
                               carStage: carStage,
                               performanceValueDisplayString: NumberFormatter.secondsFormatter.string(from: stageTiming.bestSecond) ?? "")
                }
            }
        }

    }

}

extension PerformanceTableVC.ViewModel {

    struct Row {

        let carModel: JPFanAppClient.CarModel
        let carStage: JPFanAppClient.CarStage
        let performanceValueDisplayString: String

    }

}
