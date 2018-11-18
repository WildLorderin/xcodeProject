//
//  RemindTHEREPurchaseHandler.swift
//  RemindTHERE
//
//  Created by Florian Scholz on 11.11.18.
//  Copyright © 2018 MaFlo UG. All rights reserved.
//

import Foundation
import StoreKit
import NotificationCenter

class RemindTHEREPurchaseHandler: NSObject, SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tx in transactions {
            switch(tx.transactionState) {
            case .purchased:
                unlock(productId: tx.payment.productIdentifier)
                queue.finishTransaction(tx)
                
            case .restored:
                unlock(productId: tx.original!.payment.productIdentifier)
                queue.finishTransaction(tx)
                
            case .failed:
                NSLog("%@", "Payment Queue Error: \(String(describing: tx.error))")
                queue.finishTransaction(tx)
                
            case .purchasing: break
            case .deferred: break
            }
        }
    }
    
    func unlock(productId: String) {
        
        var object: [String : Any] = ["user" : 0]
        
        if productId == "de.scholzf.remindTHERE.purchases.threeMonths" {
            object = ["status" : "premium", "coins" : 0]
        } else if productId == "de.scholzf.remindTHERE.purchases.addNotes" {
            object = ["status" : "standart", "coins" : 5]
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "purchaseUnlocked"), object: object)
    }
    
    func register() {
        SKPaymentQueue.default().add(self)
    }
    
}
