//
//  ConfirmationViewController.swift
//  MNRCH2
//
//  Created by Patty Case on 3/24/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit

class ConfirmationViewController: UIViewController {
    
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        imageView.roundCornersForAspectFit(radius: 15)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
         performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
         performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
    
}
