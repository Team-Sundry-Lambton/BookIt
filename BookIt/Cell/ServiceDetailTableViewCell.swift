//
//  ServiceDetailTableViewCell.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-11.
//

import UIKit

class ServiceDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var pricetLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    
    func configureCell(service: Service) {
        titleLbl.text = service.serviceTitle
        descriptionLbl.text = service.serviceDescription
        if let price = service.price, let type = service.priceType {
            pricetLbl.text = "$ " + price + " / " + type
        }
        locationLbl.text = service.serviceArea
        let user =  UserDefaultsManager.shared.getUserData()
        if user.firstName != "" {
            nameLbl.isHidden = false
            nameLbl.text = user.firstName + " " + user.lastName
        }else{
            nameLbl.isHidden = true
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
