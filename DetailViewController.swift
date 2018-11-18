//
//  DetailViewController.swift
//  RemindTHERE
//
//  Created by Florian Scholz on 03.11.18.
//  Copyright © 2018 MaFlo UG. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

var userLocation = CLLocation()
var toLocation = CLLocation()

class DetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate {
    
    var locationManager: CLLocationManager!
    
    let mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isZoomEnabled = true
        view.isScrollEnabled = true
        return view
    }()
    
    let titleLabel: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Titel hinzufügen..."
        view.textColor = .lightGray
        view.isScrollEnabled = false
        view.font = UIFont.boldSystemFont(ofSize: 25)
        view.textAlignment = .center
        view.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.tag = 0
        return view
    }()
    
    let submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Hinzufügen", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(submitPressed), for: .touchUpInside)
        return button
    }()
    
    let regionLabel: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Straße hinzufügen"
        view.textColor = .lightGray
        view.isScrollEnabled = false
        view.font = UIFont.boldSystemFont(ofSize: 25)
        view.textAlignment = .center
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        view.tag = 1
        return view
    }()
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func stringToCoordinate(street: String, completion: @escaping (CLLocation) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(street) { (placemarks, error) in
            
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                print("location can't be found")
                return
            }
            
            completion(location)
        }
    }
    
    func getTitle() -> String {
        return titleLabel.text
    }
    
    func getStreet() -> String {
        return regionLabel.text
    }
    
    func setAnnotation(location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.title = self.getTitle()
        annotation.subtitle = "RemindTHERE"
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    func checkCreditsAndSetPin(location: CLLocation) {
        let launchManager = LaunchManager()
        setAnnotation(location: location)
        if launchManager.isValid() {
            let userData: [String : Any] = ["status" : launchManager.getAccountState(), "coins" : 0]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "purchaseUnlocked"), object: userData)
            CoreDataHandler.addReminder(title: getTitle(), latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            reloadData = true
            self.navigationController?.popToRootViewController(animated: true)
        }else {
            print("invalid")
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1 {
            
            _ = stringToCoordinate(street: textView.text) { (location) in
                self.setAnnotation(location: location)
            }
            
            textView.isEditable = false
            textView.isSelectable = false
        }
        
        if textView.tag == 0 {
            textView.isEditable = false
            textView.isSelectable = false
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func submitPressed() {
        _ = stringToCoordinate(street: getStreet()) { (location) in
            self.checkCreditsAndSetPin(location: location)
        }
    }
    
    func setupLayout() {
        mapView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5).isActive = true
        mapView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        regionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20).isActive = true
        regionLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        regionLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
        regionLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        submitButton.topAnchor.constraint(equalTo: self.regionLabel.bottomAnchor, constant: 20).isActive = true
        submitButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 50).isActive = true
        submitButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -50).isActive = true
        submitButton.bottomAnchor.constraint(equalTo: self.mapView.topAnchor, constant: -20).isActive = true
        
        
    }
    
    @objc func setupDetail(_ notification: Notification) {
        let dict = notification.object as! NSDictionary
        let reminder = dict["reminder"] as! Reminder
        
        self.title = reminder.title
        let location = CLLocation(latitude: reminder.latitude, longitude: reminder.longitude)
        
        getPlacemark(forlocation: location) { (originPlacemark, error) in
            if let err = error {
                print(err)
            } else if let placemark = originPlacemark {
                self.setAnnotation(location: location)
                self.title = reminder.title
                self.titleLabel.text = reminder.title
                self.regionLabel.text = placemark.thoroughfare
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(regionLabel)
        self.view.addSubview(mapView)
        self.view.addSubview(submitButton)
        
        setupLayout()
        checkLocationService()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        titleLabel.delegate = self
        regionLabel.delegate = self
        
        self.view.backgroundColor = .white
        self.title = "Neue Erinnerung"
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkAuthorization()
        } else {
            //SHOW ALERT TO TURN THIS ON
        }
    }
    
    func checkAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            centerUsersViewInMap()
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .restricted:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            centerUsersViewInMap()
        }
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerUsersViewInMap() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1500, longitudinalMeters: 1500)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            userLocation = location
        }
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
    
}
