//
//  ComputerListViewController.swift
//  MNRCH2
//
//  Created by Patty Case on 3/23/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import AVFoundation
import UIKit

class ComputerListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var pairButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var deviceList:[Computer] = []
    var useCamera : Bool = false
    let imagePicker = UIImagePickerController()
    
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
    
    /**
     Returns number of components in vie
     
     - Parameter pickerview:
     
     - Throws:
     
     - Returns: int value of 1
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     Returns number of rows in component
     
     - Parameter pickerView:
     numberOfRowsInComponent
     
     - Throws:
     
     - Returns: int value of 1
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    // MARK: - Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
        //    var computersArray: [Computer] = []
        //    computersArray.append(Computer(date: "03/01/19", MAC: "00:01:02:03", image: nil))
        //    computersArray.append(Computer(date: "03/02/19", MAC: "00:01:02:03", image: nil))
        //    computersArray.append(Computer(date: "03/03/19", MAC: "00:01:02:03", image: nil))
        
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
    
    /**
     Performs image recognition
     
     - Parameter picker:
     info:
     
     - Throws:
     
     - Returns:
     */
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        // Do image recognition
//        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            imageView.image = image
//            imageView.roundCornersForAspectFit(radius: 15)
//            imagePicker.dismiss(animated: true, completion: nil)
//
//        } else {
//            print("There was an error picking the image")
//        }
//    }
    
    /**
     Called after image source is specified. If camera is chosen, camera permission is checked, and if allowed, the camera
     is displayed. If photo library is chosen, the photo library is displayed.
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func getImage() {
        
        // Check camera permission
        if (self.useCamera) {
            self.checkCameraPermission()
        }
        
        self.navigationItem.title = String.EMPTY
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     Displays an alert to choose either the camera or the photo library as the image source
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func pickImageSourceAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.CAMERA_OR_PHOTO, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        alert.addAction(UIAlertAction(title: String.CAMERA, style: .default, handler: { (UIAlertAction) in
            self.imagePicker.sourceType = .camera
            self.useCamera = true
            self.navigationItem.title = String.TAKE_A_PICTURE
            self.getImage()
        }))
        
        alert.addAction(UIAlertAction(title: String.PHOTO_LIBRARY, style: .default, handler: { (UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.useCamera = false
            self.navigationItem.title = String.SELECT_A_PICTURE
            self.getImage()
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    /**
     Checks camera permission, and displays alert if access is denied or restricted
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
            
        // The user has previously granted access to the camera.
        case .authorized:
            return
            
        // The user has not yet been asked for camera access.
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    return
                }
            }
            
            // denied - The user has previously denied access.
        // restricted - The user can't grant access due to restrictions.
        case .denied, .restricted:
            self.cameraAccessNeededAlert()
            return
            
        default:
            break
        }
    }
    
    /**
     Displays an alert saying that camera access is needed. Allows user to enable the camera.
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func cameraAccessNeededAlert() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: String.NEED_CAMERA,
            message: String.CAMERA_ACCESS_REQUIRED,
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: String.CANCEL, style: .default, handler: { (action) in
            self.noCameraAlert()
        }))
        alert.addAction(UIAlertAction(title: String.ALLOW_CAMERA, style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Displays an alert to say that the photo library will be used instead of the camera
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func noCameraAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.USING_PHOTO_LIBRARY, preferredStyle: .alert)
        alert.isModalInPopover = true
        alert.addAction(UIAlertAction(title: String.OK, style: .default, handler: { (action) in
            self.usePhotoLibrary()
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    /**
     Sets the image picker to use the photo libary as the source
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func usePhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

}

