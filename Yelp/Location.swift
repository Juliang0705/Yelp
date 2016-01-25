//
//  Location.swift
//  Yelp
//
//  Created by Juliang Li on 1/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject,CLLocationManagerDelegate{
    let locationManager = CLLocationManager()
    var currentLocation:String?
    override init(){
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        update()
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation
        currentLocation = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        locationManager.stopUpdatingLocation()
    }

    func getCurrentLocationAsString() -> String?{
        update()
        return currentLocation
    }
    func update(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
}