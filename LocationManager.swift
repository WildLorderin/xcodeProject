//
//  LocationManager.swift
//  RemindTHERE
//
//  Created by Florian Scholz on 17.11.18.
//  Copyright © 2018 MaFlo UG. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager {
    
    var streetDictionary = [String : CLLocation]()
    
    init() {
        streetDictionary =
        [
            "Privat" : CLLocation(latitude: 5, longitude: 1),
            "Uni" : CLLocation(latitude: 10, longitude: 20),
        ]
    }
    
    class func inRange(first: CLLocation, second: CLLocation, meters: Double) -> Bool {
        return distance(first: first, second: second) <= meters
    }
    
    class func distance(first firstLocation: CLLocation, second secondLocation: CLLocation) -> CLLocationDistance {
        return firstLocation.distance(from: secondLocation)
    }
    
    class func authorization() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
}
