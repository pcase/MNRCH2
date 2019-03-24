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
    
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    var manager:CBCentralManager? = nil
    var computer: Computer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        imageView.roundCornersForAspectFit(radius: 15)
        
        manager = CBCentralManager(delegate: self, queue: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
         performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        scanBLEDevices()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindSegueToVC1" {
            if let destinationVC = segue.destination as? ComputerListViewController {
                if let currentComputer = computer {
                    destinationVC.addComputerToList(computer: currentComputer)
                }
            }
        }
    }
    
    // MARK: BLE Scanning
    func scanBLEDevices() {
        //manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
        
        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
        manager?.scanForPeripherals(withServices: nil, options: nil)
        
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.stopScanForBLEDevices()
        }
    }
    
    func stopScanForBLEDevices() {
        showTimeoutAlert()
        manager?.stopScan()
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
    
    // MARK: - CBCentralManagerDelegate Methods
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        showFoundOneAlert()
        
        computer = Computer(date: getDate(), MAC: "AA:BB:CC:DD:EE:FF", image: image)
        
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter.string(from: date)
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
