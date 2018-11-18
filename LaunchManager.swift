//
//  LaunchManager.swift
//  RemindTHERE
//
//  Created by Florian Scholz on 15.11.18.
//  Copyright © 2018 MaFlo UG. All rights reserved.
//

import UIKit

final class LaunchManager {
    
    let userDefaults: UserDefaults = .standard
    let wasLaunchedBefore: Bool
    
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    func getCurrentCoins() -> Int {
        guard let coins = userDefaults.value(forKey: "de.scholz.remindTHERE.currency.coins") else { return 0 }
        return coins as! Int
    }
    
    func getAccountState() -> String {
        guard let state = userDefaults.value(forKey: "de.scholz.remindTHERE.account.status") else { return ""}
        return state as! String
    }
    
    func setAccountState(state: String) {
        userDefaults.set(state, forKey: "de.scholz.remindTHERE.account.status")
    }
    
    func setCoins(coins: Int) {
        userDefaults.set(coins, forKey: "de.scholz.remindTHERE.currency.coins")
    }
    
    func hasCoins() -> Bool {
        return getCurrentCoins() > 0
    }
    
    func isPremium() -> Bool {
        return getAccountState() == "premium"
    }
    
    func isValid() -> Bool {
        return hasCoins() || isPremium()
    }
    
    func add(coins: Int) {
        let updatedCoins = getCurrentCoins() + coins
        setCoins(coins: updatedCoins)
    }
    
    init() {
        let launchKey = "de.scholz.remindTHERE.FirstLaunched.WasLaunchedBefore"
        let coinKey = "de.scholz.remindTHERE.currency.coins"
        let accountStatus = "de.scholz.remindTHERE.account.status"
        let startingCoins = 1
        
        let wasLaunchedBefore = userDefaults.bool(forKey: launchKey)
        self.wasLaunchedBefore = wasLaunchedBefore
        
        if !wasLaunchedBefore {
            userDefaults.set(startingCoins, forKey: coinKey)
            userDefaults.set(true, forKey: launchKey)
            userDefaults.set("standart", forKey: accountStatus)
        }
    }
    
}
