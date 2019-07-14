//
//  BLEDetailsViewController.swift
//  BLECypress
//
//  Created by Monica Bura on 10/20/18.
//  Copyright © 2018 Monica Bura. All rights reserved.
//

import UIKit
import GoogleMaps

class BLEDetailsViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var detailsView: UILabel!
    
    var metadata =  [String: Any]()
    
    let locationManager = BLELocationManager()
    var loadingAlertController = UIAlertController()
    

    override func viewDidLoad() {
        initView()
        locationManager.delegate = self;
        locationManager.startReceivingSignificantLocationChanges()
        
        self.parsePeriferialAdvertismentData(advertisementData: self.metadata)
    }
    
    func initView() {
        loadingAlertController = UIAlertController(title: "Fetching location", message: nil, preferredStyle: .alert)
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = -1
        
        loadingAlertController.view.addSubview(activityIndicator)
        
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: loadingAlertController.view, attribute: .centerY, multiplier: 1.4, constant: 0)
        
        NSLayoutConstraint.activate([ xConstraint, yConstraint])
        
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: loadingAlertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 80)
        
        loadingAlertController.view.addConstraint(height);
        
        self.present(loadingAlertController, animated: false, completion: nil)
    }
    
    func parsePeriferialAdvertismentData(advertisementData: [String: Any]) {
        print(advertisementData)
        
        if let raw = advertisementData["kCBAdvDataLocalName"] as? String{
            if (raw == "IAQ") {
                self.detailsView.text = "Beacon name: \(raw) \n\n"
            } else {
                self.detailsView.text = "Beacon name: \(raw) \n\nNo advertisment data available!"
                return
            }
        } else {
            self.detailsView.text = "No beacon data available!"
            return
        }
        for (key, value)  in advertisementData {
            if key == "kCBAdvDataManufacturerData" {
                if let raw = value as? NSData {
                    let desc = raw.description
                    
                    //Example: <59002c01 fcfa703e 0000ffff fcff>
                    //IAQ: <a6028235 16252c0c 61290725>
                    let bytes = desc.components(separatedBy: " ")
                    
                    let temp_integral_string = (bytes[1] as NSString).substring(to: 2) //16
                    let temp_fractional_string = ((bytes[1] as NSString).substring(from: 2) as NSString).substring(to: 2) //25
                    let humid_integral_string = ((bytes[1] as NSString).substring(from: 4) as NSString).substring(to: 2) //2c
                    let humid_fractional_string = (bytes[1] as NSString).substring(from: 6) //0c
                    let pressure_integral_string = (bytes[2] as NSString).substring(to: 2) // 61
                    let pressure_fractional_string = ((bytes[2] as NSString).substring(from: 2) as NSString).substring(to: 2)// 29
                    
                    let temp_integral = UInt8(temp_integral_string, radix: 16)!
                    let temp_fractional = UInt8(temp_fractional_string, radix: 16)!
                    let humid_integral = UInt8(humid_integral_string, radix: 16)!
                    let humid_fractional = UInt8(humid_fractional_string, radix: 16)!
                    let pressure_integral = UInt8(pressure_integral_string, radix: 16)!
                    let pressure_fractional = UInt8(pressure_fractional_string, radix: 16)!
                    
                    print("Temperature: " + temp_integral.description +  "," + temp_fractional.description)
                    print("Humidity: "  + humid_integral.description + "," + humid_fractional.description)
                    print("Pressure: " + pressure_integral.description + "," + pressure_fractional.description)
                    self.detailsView.text = self.detailsView.text! + "Temperature: " + temp_integral.description +  "," + temp_fractional.description + "\nHumidity: "  + humid_integral.description + "," + humid_fractional.description + "\nPressure: " + pressure_integral.description + "," + pressure_fractional.description
                }
            }
        }
        
    }
    
    
}

extension BLEDetailsViewController: BLELocationManagerProtocol {
    func locationManager(_ locationManager: BLELocationManager, didUpdateLocations location: CLLocation) {
        loadingAlertController.dismiss(animated: true, completion: nil)
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 6.0)
        self.mapView.camera = camera
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = mapView
        
    }
    
    func locationManagerAccessDenied() {
        loadingAlertController.title = "Location permission denied!"
        let activityIndicator = loadingAlertController.view.viewWithTag(-1)
        activityIndicator?.removeFromSuperview()
    }
}
