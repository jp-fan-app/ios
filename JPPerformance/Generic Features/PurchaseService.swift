//
//  PurchaseService.swift
//  JPPerformance
//
//  Created by Christoph Pageler on 04.09.18.
//  Copyright © 2018 Christoph Pageler. All rights reserved.
//


import Foundation
import SwiftyStoreKit
import StoreKit


class InAppPurchase {

    static let shared = InAppPurchase()

    static let didUpdatePurchasesNotification = NSNotification.Name(rawValue: "updatedPurchases")
    static let didPurchasedNotification = NSNotification.Name(rawValue: "didPurchasedNotification")

    public private(set) var tipSmallIdentifier = "com.pageler.christoph.JPPerformance.iap.tip.small"
    public private(set) var tipSmall: SKProduct?

    public private(set) var tipMediumIdentifier = "com.pageler.christoph.JPPerformance.iap.tip.medium"
    public private(set) var tipMedium: SKProduct?

    public private(set) var tipMassiveIdentifier = "com.pageler.christoph.JPPerformance.iap.tip.massive"
    public private(set) var tipMassive: SKProduct?

    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase)")
                    self.sendUpdatePurchasesNotification()
                }
            }
        }
    }

    func retrieveProductsInfo() {
        let productIdentifiers: Set<String> = [
            tipSmallIdentifier,
            tipMediumIdentifier,
            tipMassiveIdentifier
        ]

        SwiftyStoreKit.retrieveProductsInfo(productIdentifiers) { results in
            if results.error != nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.retrieveProductsInfo()
                }
            } else {
                for product in results.retrievedProducts {
                    switch product.productIdentifier {
                    case self.tipSmallIdentifier: self.tipSmall = product
                    case self.tipMediumIdentifier: self.tipMedium = product
                    case self.tipMassiveIdentifier: self.tipMassive = product
                    default: break
                    }
                }
                self.sendUpdatePurchasesNotification()
            }
        }
    }

    func hasPurchased(product: SKProduct) -> Bool {
        return hasPurchased(productWithIdentifier: product.productIdentifier)
    }
    func hasPurchased(productWithIdentifier identifier: String) -> Bool {
        return UserDefaults.standard.bool(forKey: identifier)
    }

    func purchase(product: SKProduct?, completion: (() -> Void)? = nil) {
        guard let product = product else { return }
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: purchase.productId)

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    Review.requestReviewIfNeeded(userDemonstratedEngagement: true)
                }
                self.sendDidPurchasedNotification()
            case .error(let error):
                print("failed to purchase: \(error)")
            }
            completion?()
            self.sendUpdatePurchasesNotification()
        }
    }

    func restorePurchases(completion: (() -> Void)? = nil) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                for restoredPurchase in results.restoredPurchases {
                    UserDefaults.standard.removeObject(forKey: restoredPurchase.productId)
                }
            } else {
                print("Nothing to Restore")
            }
            completion?()
            self.sendUpdatePurchasesNotification()
        }
    }

    private func sendUpdatePurchasesNotification() {
        NotificationCenter.default.post(name: InAppPurchase.didUpdatePurchasesNotification,
                                        object: nil)
    }

    private func sendDidPurchasedNotification() {
        NotificationCenter.default.post(name: InAppPurchase.didPurchasedNotification,
                                        object: nil)
    }

}
