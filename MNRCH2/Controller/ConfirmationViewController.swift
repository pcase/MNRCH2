//
//  ConfirmationViewController.swift
//  MNRCH2
//
//  Created by Patty Case on 3/24/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD
import os.log

class ConfirmationViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UINavigationControllerDelegate {
    
    let BLEService = "EC00"
    let BLECharacteristic = "ec0e"
    var centralManager: CBCentralManager?
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    var computer: Computer?
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
        imageView.roundCornersForAspectFit(radius: 15)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        centralManager?.stopScan()
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
        SVProgressHUD.show()
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
//            self.showTimeoutAlert()
            self.stopScanForBLEDevices()
        }
    }
    
    func stopScanForBLEDevices() {
        SVProgressHUD.dismiss()
        centralManager?.stopScan()
//        self.showTimeoutAlert()
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
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
        computer = Computer(dateAdded: getDate(), MACAddress: MACAddress, image: image)
        stopScanForBLEDevices()
    }
    
    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        switch manager.state {
        case .poweredOff:
            os_log("BLE has powered off", log: OSLog.default, type: .debug)
            centralManager?.stopScan()
        case .poweredOn:
            os_log("BLE is now powered on", log: OSLog.default, type: .debug)
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        case .resetting: os_log("BLE is resetting", log: OSLog.default, type: .debug)
        case .unauthorized: os_log("Unauthorized BLE state", log: OSLog.default, type: .debug)
        case .unknown: os_log("Unknown BLE state", log: OSLog.default, type: .debug)
        case .unsupported: os_log("This platform does not support BLE", log: OSLog.default, type: .debug)
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
            
            print("Service found with UUID: ")
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
                    os_log("Found Device Name Characteristic", log: OSLog.default, type: .debug)
                }
            }
        }
        
        if (service.uuid.uuidString == "180A") {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == "2A29") {
                    peripheral.readValue(for: characteristic)
                    os_log("Found a Device Manufacturer Name Characteristic", log: OSLog.default, type: .debug)
                } else if (characteristic.uuid.uuidString == "2A23") {
                    peripheral.readValue(for: characteristic)
                    os_log("Found System ID", log: OSLog.default, type: .debug)
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
                    os_log("Found Mac Data Characteristic", log: OSLog.default, type: .debug)
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
        let alert = UIAlertController(title: String.EMPTY, message: String.NO_DEVICES_FOUND, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: false, completion: nil)
            self.performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
        }))
        
        self.present(alert, animated: true)
    }
}
