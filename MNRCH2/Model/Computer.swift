//
//  Computer.swift
//  MNRCH2
//
//  Created by Patty Case on 3/23/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import Foundation
import UIKit

class Computer : NSObject, NSCoding {

    var dateAdded: String
    var MACAddress: String
    var image: UIImage?

    init(date: String, MAC: String, image: UIImage?) {
        self.dateAdded = date
        self.MACAddress = MAC
        self.image = image
    }

    required init?(coder aDecoder: NSCoder) {
        self.dateAdded = aDecoder.decodeObject(forKey: "dateAdded") as? String ?? ""
        self.MACAddress = aDecoder.decodeObject(forKey: "MACAddress") as? String ?? ""
        self.image = aDecoder.decodeObject(forKey: "image") as? UIImage ?? nil
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dateAdded, forKey: "dateAdded")
        aCoder.encode(MACAddress, forKey: "MACAddress")
        aCoder.encode(image, forKey: "image")
    }
}

