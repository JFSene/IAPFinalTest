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
	
	let inAppPurchase = "com.biologiatotal.019283746547382910"
	override func viewDidLoad() {
		super.viewDidLoad()
        SwiftyStoreKit.retrieveProductsInfo([inAppPurchase]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
                DispatchQueue.main.async {
                    self.renewableButton?.setTitle("\(product.localizedDescription), price: \(priceString)", for: .normal)
                }
                
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
		
//        verifyPurchase(inAppPurchase, sharedSecret: sharedSecret)
        verifySubscription(inAppPurchase, sharedSecret, .autoRenewable, nil)
	}

	@IBAction func renewableAction(_ sender: Any) {
        self.purchaseSubscription(inAppPurchase, sharedSecret, .autoRenewable, nil)
	}
	
	@IBAction func nonRenewableAction(_ sender: Any) {
	}
	
}


extension ViewController {
    
    func purchaseSubscription(_ id: String, _ sharedSecret: String, _ type: SubscriptionType, _ validDuration: TimeInterval?) {
        SwiftyStoreKit.purchaseProduct(id, atomically: true) { result in
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                self.verifySubscription(id, sharedSecret, type, validDuration)
                
//                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
//                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//
//                    if case .success(let receipt) = result {
//                        let purchaseResult = SwiftyStoreKit.verifySubscription(
//                            ofType: .autoRenewable,
//                            productId: id,
//                            inReceipt: receipt)
//
//                        switch purchaseResult {
//                        case .purchased(let expiryDate):
//                            print("Product is valid until \(expiryDate)")
//                        case .expired(let expiryDate):
//                            print("Product is expired since \(expiryDate)")
//                        case .notPurchased:
//                            print("This product has never been purchased")
//                        }
//
//                    } else {
//                        // receipt verification error
//                    }
//                }
            } else {
                // purchase error
            }
        }
    }
	
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
    
    enum SubscriptionType: Int {
        case autoRenewable = 0,
        nonRenewing
    }
    
    func verifySubscription(_ productId: String?, _ sharedSecret: String, _ type:  SubscriptionType, _ validDuration: TimeInterval?) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                switch type {
                case .autoRenewable:
                    if let id = productId {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable, // or .nonRenewing (see below)
                            productId: id,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let items):
                            print("\(id) is valid until \(expiryDate)\n\(items)\n")
                        case .expired(let expiryDate, let items):
                            print("\(id) is expired since \(expiryDate)\n\(items)\n")
                        case .notPurchased:
                            print("The user has never purchased \(id)")
                        }
                    }
                case .nonRenewing:
                    guard let validDuration = validDuration else { return }
                    if let id = productId {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .nonRenewing(validDuration: validDuration),
                            productId: id,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let items):
                            print("\(id) is valid until \(expiryDate)\n\(items)\n")
                        case .expired(let expiryDate, let items):
                            print("\(id) is expired since \(expiryDate)\n\(items)\n")
                        case .notPurchased:
                            print("The user has never purchased \(id)")
                        }
                    }
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
}
