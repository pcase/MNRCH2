//
//  PairComputerViewController.swift
//  MNRCH2
//
//  Created by Patty Case on 3/23/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class PairComputerViewController: UIViewController, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    var useCamera : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        getImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ConfirmationViewController
        {
            let vc = segue.destination as? ConfirmationViewController
            vc?.image = self.imageView.image
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    /**
     Pick image
     
     - Parameter picker:
     info:
     
     - Throws:
     
     - Returns:
     */
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageView.image = image
                imageView.roundCornersForAspectFit(radius: 15)
                imagePicker.dismiss(animated: true, completion: nil)
                showGuessAlert()
            } else {
                print("There was an error picking the image")
            }
        }
    
    /**
     Called after image source is specified. If camera is chosen, camera permission is checked, and if allowed, the camera
     is displayed. If photo library is chosen, the photo library is displayed.
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func getImage() {
        
        if (self.useCamera) {
            self.checkCameraPermission()
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
        
        self.navigationItem.title = String.EMPTY
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
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
    
    /**
     Displays an alert to show the guess
     
     - Parameter guess: string representing the guess
     
     - Throws:
     
     - Returns:
     */
    func showGuessAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.IS_IT + String.SPACE + String.DOUBLE_QUOTE + String.LAPTOP + String.DOUBLE_QUOTE, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        alert.addAction(UIAlertAction(title: String.YES, style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "showConfirmationView", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: String.NO, style: .default, handler: { (UIAlertAction) in
            for controller in self.navigationController!.viewControllers as Array {
                if let vc = controller as? ComputerListViewController {
                    vc.currentComputer = nil
                    _ =  self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }))
        self.present(alert,animated: true, completion: nil )
    }
}
