//
//  CategoryListCollectionViewCell.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-11.
//

import UIKit

class CategoryListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    
    func configureCell(category: Category) {
        if let title = category.name {
            self.serviceName.text = title
        }
        
        if let imageData = category.picture {
            self.serviceImage.downloaded(from: imageData)
       //     self.serviceImage.image = UIImage(data: imageData)
        }
    }
}
