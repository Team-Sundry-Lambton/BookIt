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
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var lblRating: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        addBorder()
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
