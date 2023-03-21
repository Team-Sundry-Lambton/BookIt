//
//  VendorServiceListTableViewCell.swift
//  BookIt
//
//  Created by Tilak Acharya on 2023-03-17.
//

import Foundation
import UIKit

class VendorServiceListTableViewCell : UITableViewCell{
    
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    func configureCell(service: Service) {
        
        titleLbl.text = service.serviceTitle
        descLbl.text = service.serviceDescription
        if let price = service.price, let type = service.priceType {
            priceLbl.text = "$ " + price + " / " + type
        }
        
//        if let imageData = mediaList[0].image {
//            self.serviceImage.image = UIImage(data: imageData)
//        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
