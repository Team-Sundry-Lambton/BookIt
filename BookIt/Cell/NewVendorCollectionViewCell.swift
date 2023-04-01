//
//  NewVendorCollectionViewCell.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-20.
//

import UIKit

class NewVendorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var vendorImage: UIImageView!
    @IBOutlet weak var vendorName: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    
    func configureCell(vendor: Vendor) {
        if let imageData = vendor.picture {
            self.vendorImage.image = UIImage(data: imageData)
        }
        if let firstName = vendor.firstName, let lastName = vendor.lastName {
            vendorName.text = firstName + " " + lastName
        }
        dipalyVendorReview(email: vendor.email ?? "")
    }
    
    func dipalyVendorReview(email : String){
       var vendorReviewList = CoreDataManager.shared.getVendorReviewList(email: email)
        var reviewTotal = 0
        var rate = 0
        for review in vendorReviewList {
            reviewTotal += Int(review.rating)
        }
        if vendorReviewList.count > 0 {
            rate = reviewTotal / vendorReviewList.count
        }
        lblRating.text = String(rate)
    }
}
