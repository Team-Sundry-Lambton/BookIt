//
//  NewVendorCollectionViewCell.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-20.
//

import UIKit

class NewVendorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var vendorImage: UIImageView!
    
    func configureCell(vendor: Vendor) {
        if let imageData = vendor.picture {
            self.vendorImage.image = UIImage(data: imageData)
        }
    }
}
