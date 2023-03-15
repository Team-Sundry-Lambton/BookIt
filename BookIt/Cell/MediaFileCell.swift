//
//  MediaFileCell.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-08.
//

import UIKit

class MediaFileCell: UICollectionViewCell {
    @IBOutlet weak var mediaImage: UIImageView!
    @IBOutlet weak var removeIcon: UIImageView!
    
    class var reuseIdentifier: String {
        return "MediaFileCell"
    }
    class var nibName: String {
        return "MediaFileCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(file: MediaFile? , indexPath :IndexPath) {
        if indexPath.row == 0 {
            self.mediaImage.image = UIImage(named: "AddMedia")
            removeIcon.isHidden = true

        }else{
            if let object = file {
                removeIcon.isHidden = true
                if let imageData = object.mediaContent {
                    self.mediaImage.image = UIImage(data: imageData)
                }
            }
        }
    }
}
