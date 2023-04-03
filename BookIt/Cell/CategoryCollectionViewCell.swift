//
//  CategoryCollectionViewCell.swift
//  BookIt
//
//  Created by Sonia Nain on 2023-03-09.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
        }
    
    override func layoutSubviews() {
            super.layoutSubviews()
            
            // Make the cell round
            layer.cornerRadius = 10
            layer.masksToBounds = true
        }
    
}
