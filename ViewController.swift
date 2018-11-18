//
//  ViewController.swift
//  RemindTHERE
//
//  Created by Florian Scholz on 03.11.18.
//  Copyright © 2018 MaFlo UG. All rights reserved.
//

import UIKit
import StoreKit
import CoreLocation
import CoreData

var reloadData: Bool = false

class ViewController: UITableViewController {
    
    var request: SKProductsRequest!
    var products: [SKProduct] = []
    var productIdentifiers = Set(["de.scholzf.remindTHERE.purchases.addNotes", "de.scholzf.remindTHERE.purchases.threeMonths"])
    var purchaseButton = UIBarButtonItem()
    
    let defaults = UserDefaults.standard
    let searchController = UISearchController(searchResultsController: nil)
    let launchManager = LaunchManager()
    
    func setupNavigationBar() {
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Suchen"
        
        self.navigationItem.searchController = searchController
        
        self.definesPresentationContext = true
        self.title = "RemindTHERE"
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEvent(sender:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetCredits))
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
  
    @objc func resetCredits(){
        launchManager.setCoins(coins: 0)
        CoreDataHandler.deleteAllData("Reminder")
        self.receiveCoreData()
    }
    
    @objc func updateToolBar(_ notification: Notification) {
        let dict = notification.object as! NSDictionary
        let status = dict["status"] as! String
        let coins = dict["coins"] as! Int
        let currentCoins = launchManager.getCurrentCoins()
        let totalCoins = currentCoins + coins
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        if status == "premium" {
            launchManager.setCoins(coins: totalCoins)
            purchaseButton.setTitle(title: "Premium Mitglied")
        } else if status == "standart" {
            launchManager.setCoins(coins: totalCoins)
            purchaseButton.setTitle(title: "Du hast noch \(totalCoins) Notizen über")
        }
        
        purchaseButton.style = .done
        purchaseButton.target = self
        purchaseButton.action = #selector(purchaseItemPressed)
        purchaseButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], for: .normal)
        
        let arr: [Any] = [space, purchaseButton, space]
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.setToolbarItems(arr as? [UIBarButtonItem] ?? [UIBarButtonItem](), animated: true)
    }
    
    func setupToolBar() {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let status = launchManager.getAccountState()
        let coins = launchManager.getCurrentCoins()
        
        if status == "premium" {
            purchaseButton.setTitle(title: "Premium Mitglied")
            launchManager.setCoins(coins: 5)
        } else if status == "standart" {
            purchaseButton.setTitle(title: "Du hast noch \(coins) Notizen über")
        }
    
        purchaseButton.style = .done
        purchaseButton.target = self
        purchaseButton.action = #selector(purchaseItemPressed)
        purchaseButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray], for: .normal)
        
        let arr: [Any] = [space, purchaseButton, space]
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.setToolbarItems(arr as? [UIBarButtonItem] ?? [UIBarButtonItem](), animated: true)
    }
    
    @objc func purchaseItemPressed() {
        
        let alertView = UIAlertController(title: "Käufe", message: "Wähle eine Option aus", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Abbrechen", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        let buyExtraNotes = UIAlertAction(title: "Extra Notizen", style: .default) { (action) in
            self.purchase(index: 0)
        }
        
        let buySubscription = UIAlertAction(title: "3 Monate Premium", style: .default) { (action) in
            self.purchase(index: 1)
        }
        
        alertView.addAction(buyExtraNotes)
        alertView.addAction(buySubscription)
        alertView.addAction(cancel)
        
        self.present(alertView, animated: true, completion: nil)
    }
    
    func purchase(index: Int) {
        let product = products[index]
        let payment = SKPayment(product: product)
        
        SKPaymentQueue.default().add(payment)
    }
    
    @objc func addEvent(sender: UIBarButtonItem) {
        let vc = DetailViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func checkFirstLaunch() {
        if launchManager.isFirstLaunch {
            launchManager.setAccountState(state: "standart")
            launchManager.setCoins(coins: 5)
            
            let welcomeAlert = UIAlertController(title: "Willkommen", message: "Herzlich Willkommen", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay 👌", style: .default) { (action) in
                welcomeAlert.dismiss(animated: true, completion: nil)
            }
            
            welcomeAlert.addAction(okay)
            
            self.present(welcomeAlert, animated: true, completion: nil)
        }
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateToolBar(_:)), name: NSNotification.Name("purchaseUnlocked"), object: nil)
    }
    
    func receiveCoreData() {
        CoreDataHandler.load()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if reloadData {
            self.receiveCoreData()
            reloadData.toggle()
        }
        
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        checkFirstLaunch()
        setupNavigationBar()
        setupToolBar()
        registerNotification()
        receiveCoreData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.request = SKProductsRequest(productIdentifiers: productIdentifiers)
        self.request.delegate = self
        self.request.start()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let reminders = CoreDataHandler.getReminders()
        let reminder = reminders[indexPath.row]
        let location = CLLocation(latitude: reminder.latitude, longitude: reminder.longitude)
        
        cell.textLabel?.text = reminder.title
        
        getPlacemark(forlocation: location) { (originPlacemark, error) in
            if let err = error {
                print(err)
            } else if let placemark = originPlacemark {
                cell.detailTextLabel?.text = placemark.thoroughfare
            }
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminder.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let currentReminder = reminder[indexPath.row]
        let detailViewController = DetailReminderViewController()
        let object: [String : Any] = ["reminder": currentReminder]
        
        detailViewController.setupReminderData(reminder: currentReminder)
        
        let locationManager = CLLocationManager()
        
        if let userLocation = locationManager.location {
            let objLocation = CLLocation(latitude: currentReminder.latitude, longitude: currentReminder.longitude)
            let distance = (userLocation.distance(from: objLocation) *  1,60934)
            print("\(distance.0.rounded(to: 3))m")
            print("\((distance.0 / 1000).rounded(to: 3)) km")
        }
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func getPlacemark(forlocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let err = error {
                completionHandler(nil, err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, "Placemark was nil")
                }
            } else {
                completionHandler(nil, "unknown error")
            }
        }
    }
    
    func checkLocation() {
        if LocationManager.authorization() == .authorizedWhenInUse {
            
        }
    }
    
}

extension ViewController: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        self.tableView.reloadData()
        self.request = nil
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        NSLog("%@", error as NSError)
        self.request = nil
    }
    
}

extension UIBarButtonItem {
    func setTitle(title: String) {
        self.title = title
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
