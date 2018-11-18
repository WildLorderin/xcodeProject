//
//  DetailReminderViewController.swift
//  RemindTHERE
//
//  Created by Florian Scholz on 03.11.18.
//  Copyright © 2018 MaFlo UG. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class DetailReminderViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, MKMapViewDelegate {
    
    var locationManager: CLLocationManager!
    var fromLocation: CLLocation!
    var currentReminder: Reminder!
    
    let mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Titel"
        view.textColor = .lightGray
        view.isScrollEnabled = false
        view.isEditable = false
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
        button.setTitle("In Karten öffnen", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openInMaps), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()
    
    let regionLabel: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "Straße"
        view.textColor = .lightGray
        view.isScrollEnabled = false
        view.isEditable = false
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
    
    func openAppleMaps(from: CLLocation, to: CLLocation) {
        let url_ = "https://maps.apple.com/maps?saddr\(from.coordinate.latitude),\(from.coordinate.longitude)&daddr=\(to.coordinate.latitude),\(to.coordinate.longitude)"
        let url = URL(string: url_)
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    @objc func openInMaps() {
        let from = userLocation
        let to = CLLocation(latitude: currentReminder.latitude, longitude: currentReminder.longitude)
        openAppleMaps(from: from, to: to)
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
    
    func setupReminderData(reminder: Reminder) {
        
        let location = CLLocation(latitude: reminder.latitude, longitude: reminder.longitude)
        self.currentReminder = reminder
        let street = getPlacemark(forlocation: location) { (originPlacemark, error) in
            if let err = error {
                print(err)
            } else if let placemark = originPlacemark {
                self.title = reminder.title
                self.titleLabel.text = reminder.title
                self.regionLabel.text = placemark.thoroughfare
                self.setAnnotation(location: location)
                self.showRouteOnMap(pickupCoordinate: userLocation.coordinate, destinationCoordinate: location.coordinate)
            }
        }
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        sourceAnnotation.coordinate = pickupCoordinate
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .any
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
    
    func setAnnotation(location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.title = self.title
        annotation.subtitle = "RemindTHERE"
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(titleLabel)
        self.view.addSubview(regionLabel)
        self.view.addSubview(mapView)
        self.view.addSubview(submitButton)
        
        setupLayout()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        titleLabel.delegate = self
        regionLabel.delegate = self
        
        self.view.backgroundColor = .white
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func centerUsersViewInMap() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    
}
