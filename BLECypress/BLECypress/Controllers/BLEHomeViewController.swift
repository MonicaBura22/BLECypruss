//
//  ViewController.swift
//  BLECypress
//
//  Created by Monica Bura on 10/10/18.
//  Copyright © 2018 Monica Bura. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEHomeViewController: UIViewController {
    
    @IBOutlet weak var peripherialsTableView: UITableView!
    @IBOutlet weak var beaconsLoadingIndicator: UIActivityIndicatorView!
    
    var centralManager: CBCentralManager!
    var peripherialsArray: [CBPeripheral] = [CBPeripheral]()
    var advertismentDataDictionary = [String: Any]()
    var selectedRowIndex: Int = 0
    
    override func viewDidLoad() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.beaconsLoadingIndicator.startAnimating()
        
        self.peripherialsTableView.delegate = self
        self.peripherialsTableView.dataSource = self
        
        let cell = UINib(nibName: "BeaconTableViewCell", bundle: nil)
        self.peripherialsTableView.register(cell, forCellReuseIdentifier: "BeaconTableViewCell")
    }
}


extension BLEHomeViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                print("--- Stop beacon scanning!")
               self.centralManager.stopScan()
               self.peripherialsTableView.reloadData()
                self.beaconsLoadingIndicator.stopAnimating()
            })
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if (!self.peripherialsArray.contains(peripheral)) {
            self.peripherialsArray.append(peripheral)
            self.advertismentDataDictionary[peripheral.name ?? "empty"] = advertisementData
        }
    }
    
    
    func parsePeriferialAdvertismentData(peripheral: CBPeripheral, advertisementData: [String: Any]) {
        print(advertisementData)
        if (peripheral.identifier.uuidString == "0B41DCB6-DF26-4143-9C3F-0D2B2DADF5F0"){
        
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
                        
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PeripherialToDetailsSegue" {
            if let destinationVC = segue.destination as? BLEDetailsViewController {
                let peripherial = self.peripherialsArray[self.selectedRowIndex]
                let metadata = self.advertismentDataDictionary[peripherial.name ?? "empty"]
                destinationVC.metadata = metadata as! [String : Any]
            }
        }
    }
}

extension BLEHomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRowIndex = indexPath.row
        self.performSegue(withIdentifier: "PeripherialToDetailsSegue", sender: nil)
    }
    
}

extension BLEHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherialsArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconTableViewCell") as? BeaconTableViewCell
        let peripherial = self.peripherialsArray[indexPath.row]
        
        cell?.backgroundImage.image = UIImage.init(named: self.getBackgroundImage())
        cell?.contentLabel.text = peripherial.name != nil ? peripherial.name : "empty"
        cell?.backgroundColor = UIColor.clear
        cell?.selectionStyle = .none
        
        return cell!
    }
    
    
    func getBackgroundImage() -> String {
        let backgrounds = ["cell-background-blue", "cell-background-pink", "cell-background-yellow", "cell-background-purple"]
        let index = Int(arc4random_uniform(UInt32(backgrounds.count)))
        return backgrounds[index]
    }
    
}


