//
//  AppDelegate.swift
//  IAP Final Teste
//
//  Created by T.I on 10/10/19.
//  Copyright © 2019 T.I. All rights reserved.
//

import UIKit
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// see notes below for the meaning of Atomic / Non-Atomic
		SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
			for purchase in purchases {
				switch purchase.transaction.transactionState {
				case .purchased, .restored:
					if purchase.needsFinishTransaction {
						// Deliver content from server, then:
						SwiftyStoreKit.finishTransaction(purchase.transaction)
					}
					// Unlock content
				case .failed, .purchasing, .deferred:
					break // do nothing
				@unknown default:
					fatalError()
				}
			}
		}
		return true
	}


}

