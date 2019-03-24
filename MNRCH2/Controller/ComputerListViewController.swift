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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        
        let computerList = loadComputers()
        if computerList.count == 0 {
            populateList()
            saveComputers(computersArray: deviceList)
        } else {
            deviceList.append(contentsOf: computerList)
        }
    }
    
    func populateList() {
        for _ in 1...5 {
            let computer = Computer(date: "03/22/19", MAC: "01:02:03:04", image: nil)
            deviceList.append(computer)
        }
    }
    
    @IBAction func pairButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddImageView", sender: self)
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
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
//        cell.deviceImage.image=UIImage(cgImage: <#T##CGImage#>)
        
        return cell
    }

    func saveComputers(computersArray: [Computer]) {
        
        let computersData = NSKeyedArchiver.archivedData(withRootObject: computersArray)
        UserDefaults.standard.set(computersData, forKey: "computers")
    }
    
    func loadComputers() -> [Computer] {
        var computersArray: [Computer] = []
        guard let computersData = UserDefaults.standard.object(forKey: "computers") as? NSData else {
            print("'computers' not found in UserDefaults")
            return computersArray
        }
        
        guard let tempArray = NSKeyedUnarchiver.unarchiveObject(with: computersData as Data) as? [Computer] else {
            print("Could not unarchive from computersData")
            return computersArray
        }
        
        computersArray.append(contentsOf: tempArray)

        return computersArray
    }
}

