//
//  ComputerListViewController.swift
//  MNRCH2
//
//  Created by Patty Case on 3/23/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit

class ComputerListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var pairButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var deviceList:[Computer] = []
    
    var currentComputer: Computer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        let computerList = loadComputers()
        deviceList.removeAll()
        deviceList.append(contentsOf: computerList)
    }
    
    @IBAction func pairButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddImageView", sender: self)
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        print("did unwinding")
        if let currentCurrentComputer = currentComputer {
            addComputerToList(computer: currentCurrentComputer)
        }
    }
    
    /**
     Returns number of components in vie
     
     - Parameter pickerview:
     
     - Throws:
     
     - Returns: int value of 1
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath) as! TableViewCell
        
        let computer = deviceList[indexPath.row]
        cell.MACAddress.text = computer.MACAddress
        cell.dateAdded.text = computer.dateAdded
        cell.imageView?.image = computer.image
        
        return cell
    }
    
    func addComputerToList(computer: Computer) {
        if deviceList.count == 0 {
            deviceList.append(computer)
        } else {
            for device in deviceList {
                if device.MACAddress == computer.MACAddress {
                    showDuplicateDeviceError()
                } else {
                    deviceList.append(computer)
                    saveComputers(computersArray: deviceList)
                }
            }
        }
        self.tableView.reloadData()
    }

    func clearComputers() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    func saveComputers(computersArray: [Computer]) {
        clearComputers()
        do {
            let computersData = try NSKeyedArchiver.archivedData(withRootObject: computersArray, requiringSecureCoding: false)
            UserDefaults.standard.set(computersData, forKey: "computers")
        } catch {
            print("Error occurred during data archival")
        }
    }
    
    func loadComputers() -> [Computer] {
        var computersArray: [Computer] = []
        guard let computersData = UserDefaults.standard.object(forKey: "computers") as? NSData else {
                print("'computers' not found in UserDefaults")
                return computersArray
        }
        
        do {
            guard let tempArray = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(computersData as Data) as? [Computer] else {
                    print("Could not unarchive from computersData")
                    return computersArray
            }
            computersArray.append(contentsOf: tempArray)
        } catch {
             print("Error occurred during data unarchival")
        }
        
        return computersArray
    }
    
    /**
     Displays an alert for duplicate computer
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func showDuplicateDeviceError() {
        print("duplicate device")
        let alert = UIAlertController(title: String.EMPTY, message: String.DUPLICATE_DEVICE, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        alert.addAction(UIAlertAction(title: String.OK, style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: false, completion: nil)
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: ComputerListViewController.self) {
                    _ =  self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }))
        
        self.present(alert,animated: true, completion: nil )
    }
}
