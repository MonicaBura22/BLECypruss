//
//  BLELocationManager.swift
//  BLECypress
//
//  Created by Monica Bura on 12/2/18.
//  Copyright © 2018 Monica Bura. All rights reserved.
//

import UIKit
import GoogleMaps

class BLELocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
    var delegate: BLELocationManagerProtocol?
    
    override init() {}
    
    func requestLocationAuthorization() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
            return
        }
    }
    
    func startReceivingSignificantLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse {
            delegate?.locationManagerAccessDenied()
            return
        }
        
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // The service is not available.
            return
        }
        
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopReceivingSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        stopReceivingSignificantLocationChanges()
        let lastLocation = locations.last!
        
        delegate?.locationManager(self, didUpdateLocations: lastLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopMonitoringSignificantLocationChanges()
            return
        }
        // Notify the user of any errors.
    }
}


