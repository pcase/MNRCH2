//
//  ConfirmationViewController.swift
//  MNRCH2
//
//  Created by Patty Case on 3/24/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConfirmationViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let BLEService = "EC00"
    let BLECharacteristic = "ec0e"
    var centralManager: CBCentralManager?
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    var computer: Computer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
//        self.centralManager?.delegate = self

        imageView.image = image
        imageView.roundCornersForAspectFit(radius: 15)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        for controller in self.navigationController!.viewControllers as Array {
            if let vc = controller as? ComputerListViewController {
                vc.currentComputer = nil
                _ =  self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
        self.centralManager?.delegate = self
        scanBLEDevices()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindSegueToVC1" {
            if let destinationVC = segue.destination as? ComputerListViewController {
                if let currentComputer = computer {
                    destinationVC.currentComputer = currentComputer
                }
            }
        }
    }
    
    // MARK: BLE Scanning
    func scanBLEDevices() {
        
        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
        
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopScanForBLEDevices()
        }
    }
    
    func stopScanForBLEDevices() {
//        showTimeoutAlert()
        print("timed out")
        centralManager?.stopScan()
        for controller in self.navigationController!.viewControllers as Array {
            if let vc = controller as? ComputerListViewController {
                vc.currentComputer = computer
                _ =  self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    // MARK: - CBCentralManagerDelegate Methods
    
    func centralManager(_ manager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData advertisement: [String : Any], rssi: NSNumber) {

        var MACAddress: String = ""
        if let name = peripheral.name {
            MACAddress = name
            print("Found \"\(name)\" peripheral (RSSI: \(rssi))")
        } else {
            MACAddress = "AA:BB:CC:DD:EE:FF"
            print("Found unnamed peripheral (RSSI: \(rssi))")
        }
        computer = Computer(date: getDate(), MAC: MACAddress, image: image)
//        centralManager?.stopScan()
//        for controller in self.navigationController!.viewControllers as Array {
//            if let vc = controller as? ComputerListViewController {
//                vc.currentComputer = computer
//                _ =  self.navigationController!.popToViewController(controller, animated: true)
//                    break
//            }
//        }
    }
    
    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        switch manager.state {
        case .poweredOff:
            print("BLE has powered off")
            centralManager?.stopScan()
        case .poweredOn:
            print("BLE is now powered on")
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        case .resetting: print("BLE is resetting")
        case .unauthorized: print("Unauthorized BLE state")
        case .unknown: print("Unknown BLE state")
        case .unsupported: print("This platform does not support BLE")
        }
    }
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // MARK: CBPeripheralDelegate Methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        for service in peripheral.services! {
            
            print("Service found with UUID: " + service.uuid.uuidString)
            
            //device information service
            if (service.uuid.uuidString == "180A") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //GAP (Generic Access Profile) for Device Name
            // This replaces the deprecated CBUUIDGenericAccessProfileString
            if (service.uuid.uuidString == "1800") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //Bluno Service
            if (service.uuid.uuidString == BLEService) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //get device name
        if (service.uuid.uuidString == "1800") {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == "2A00") {
                    peripheral.readValue(for: characteristic)
                    print("Found Device Name Characteristic")
                }
            }
        }
        
        if (service.uuid.uuidString == "180A") {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == "2A29") {
                    peripheral.readValue(for: characteristic)
                    print("Found a Device Manufacturer Name Characteristic")
                } else if (characteristic.uuid.uuidString == "2A23") {
                    peripheral.readValue(for: characteristic)
                    print("Found System ID")
                }
            }
        }
        
        if (service.uuid.uuidString == BLEService) {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == BLECharacteristic) {
                    //we'll save the reference, we need it to write data
                    mainCharacteristic = characteristic
                    
                    //Set Notify is useful to read incoming data async
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Found Mac Data Characteristic")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (characteristic.uuid.uuidString == "2A00") {
            //value for device name recieved
            let deviceName = characteristic.value
            print(deviceName ?? "No Device Name")
        } else if (characteristic.uuid.uuidString == "2A29") {
            //value for manufacturer name recieved
            let manufacturerName = characteristic.value
            print(manufacturerName ?? "No Manufacturer Name")
        } else if (characteristic.uuid.uuidString == "2A23") {
            //value for system ID recieved
            let systemID = characteristic.value
            print(systemID ?? "No System ID")
        } else if (characteristic.uuid.uuidString == BLECharacteristic) {
            //data received
            if(characteristic.value != nil) {
                let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
            }
        }
    }
    
    /**
     Displays an alert to announce the timeout
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func showTimeoutAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.TIMED_OUT, preferredStyle: .alert)
        alert.isModalInPopover = true
    
        self.present(alert,animated: true, completion: nil )
    }
    
    /**
     Displays an alert to announce discovery
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func showFoundOneAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.FOUND_ONE, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        self.present(alert,animated: true, completion: nil )
    }
}
