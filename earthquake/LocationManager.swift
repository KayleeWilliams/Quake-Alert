//
//  LocationManager.swift
//  earthquake
//
//  Created by Kaylee Williams on 28/12/2022.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    let manager: CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    // Request user location
    func getLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }

}
