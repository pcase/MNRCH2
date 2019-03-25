//
//  ComputerListViewController.swift
//  MNRCH2
//
//  Created by Patty Case on 3/23/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit
import SVProgressHUD
import os.log

class ComputerListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var pairButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var computers = [Computer]()
    var currentComputer: Computer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedComputers = loadComputers() {
            computers.removeAll()
            computers.append(contentsOf: savedComputers)
        }
        
        if let currentCurrentComputer = currentComputer {
            addComputerToList(computer: currentCurrentComputer)
        }
        saveComputers()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let savedComputers = loadComputers() {
            computers.removeAll()
            computers.append(contentsOf: savedComputers)
        }

        if let currentCurrentComputer = currentComputer {
            addComputerToList(computer: currentCurrentComputer)
        }
        saveComputers()
    }
    
    @IBAction func pairButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddImageView", sender: self)
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
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
        return computers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath) as! TableViewCell
        
        let computer = computers[indexPath.row]
        cell.MACAddress.text = computer.MACAddress
        cell.dateAdded.text = computer.dateAdded
        cell.imageView?.image = computer.image
        
        return cell
    }
    
    func addComputerToList(computer: Computer) {
        var found: Bool = false
        for comp in computers {
            if comp.MACAddress == computer.MACAddress {
                found = true;
            }
        }
        if !found {
            computers.append(computer)
        } else {
//            showDuplicateDeviceError()
        }
        saveComputers()
        currentComputer = nil;
        self.tableView.reloadData()
    }

    /**
     Displays an alert for duplicate computer
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func showDuplicateDeviceError() {
        let alert = UIAlertController(title: String.EMPTY, message: String.DUPLICATE_DEVICE, preferredStyle: .alert)
    
        self.present(alert, animated: true)
    }
    
    //MARK: Private Methods
    
    private func saveComputers() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(computers, toFile: Computer.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Computers successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save computers...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadComputers() -> [Computer]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Computer.ArchiveURL.path) as? [Computer]
    }
}
