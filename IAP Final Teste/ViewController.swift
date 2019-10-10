//
//  ViewController.swift
//  IAP Final Teste
//
//  Created by T.I on 10/10/19.
//  Copyright © 2019 T.I. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class ViewController: UIViewController {
	public var sharedSecret: String = "5278400eb6154bcebbd1dd3659640148"
	@IBOutlet weak var renewableButton: UIButton!
	@IBOutlet weak var nonRenewableButton: UIButton!
	
	let inAppPurchase = [
		["com.musevisions.iOS.SwiftyStoreKit"],
		["com.appteste.3monthsOfRandom"],
	]
	override func viewDidLoad() {
		super.viewDidLoad()
		let inAppPurchaseButtons = [
			[renewableButton],
			[nonRenewableButton],
		]
		
		for i in 0...inAppPurchase.count - 1 {
			for j in 0...inAppPurchase[1].count - 1 {
				SwiftyStoreKit.retrieveProductsInfo([inAppPurchase[i][j]]) { result in
					if let product = result.retrievedProducts.first {
						let priceString = product.localizedPrice!
						print("Product: \(product.localizedDescription), price: \(priceString)")
						inAppPurchaseButtons[i][j]?.setTitle("\(product.localizedDescription), price: \(priceString)", for: .normal)
					}
					else if let invalidProductId = result.invalidProductIDs.first {
						print("Invalid product identifier: \(invalidProductId)")
					}
					else {
						print("Error: \(result.error)")
					}
				}
			}
		}
		
		verifyPurchase(inAppPurchase[1][0], sharedSecret: sharedSecret)
	}

	@IBAction func renewableAction(_ sender: Any) {
	}
	
	@IBAction func nonRenewableAction(_ sender: Any) {
	}
	
}


extension ViewController {
	
	func verifyPurchase(_ id: String, sharedSecret: String) {
		let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
		SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
			switch result {
			case .success(let receipt):
				// Verify the purchase of Consumable or NonConsumable
				let purchaseResult = SwiftyStoreKit.verifyPurchase(
					productId: id,
					inReceipt: receipt)
					
				switch purchaseResult {
				case .purchased(let receiptItem):
					print("\(id) is purchased: \(receiptItem)")
				case .notPurchased:
					print("The user has never purchased \(id)")
				}
			case .error(let error):
				print("Receipt verification failed: \(error)")
			}
		}
	}
}
