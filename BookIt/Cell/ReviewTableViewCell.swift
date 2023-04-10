//
//  ReviewTableViewCell.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-03-23.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var ivAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblContent: UITextView!
    @IBOutlet weak var lblRating: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        addBorder()
    }
    
    func configureCell(vendorReview: VendorReview) {

        if let user = vendorReview.vendor {
            if let imageData = user.picture {
                self.ivAvatar.image = UIImage(data: imageData)
            }
            if let firstName = user.firstName, let lastName = user.lastName {
                lblName.isHidden = false
                lblName.text = firstName + " " + lastName
            }else{
                lblName.isHidden = true
            }
        }
        lblDateTime.text = vendorReview.date?.dateAndTimetoString()
        lblContent.text = vendorReview.comment
        lblRating.text = String(vendorReview.rating)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func addBorder() {
        ivAvatar.layer.borderColor = UIColor.white.cgColor
        ivAvatar.layer.masksToBounds = true
        ivAvatar.contentMode = .scaleToFill
        ivAvatar.layer.borderWidth = 5
        ivAvatar.layer.cornerRadius = ivAvatar.frame.height / 2
    }

}
