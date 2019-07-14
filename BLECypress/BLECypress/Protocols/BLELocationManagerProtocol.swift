//
//  BLELocationManagerProtocol.swift
//  BLECypress
//
//  Created by Monica Bura on 12/2/18.
//  Copyright © 2018 Monica Bura. All rights reserved.
//

import UIKit
import GoogleMaps

protocol BLELocationManagerProtocol: class {
    func locationManager(_ locationManager: BLELocationManager,
                         didUpdateLocations location: CLLocation)
    func locationManagerAccessDenied()
}
