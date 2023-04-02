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
    
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configureCell(service: Service) {
        
        if let title = service.serviceTitle {
            titleLbl.text = title
        }
        if let description = service.serviceDescription {
            descLbl.text = description
        }
        if let price = service.price, let type = service.priceType {
            priceLbl.text = "$ " + price + " / " + type
        }
        if let address =  service.address {
            locationLbl.isHidden = false
            locationLbl.text =  address.address
        }else{
            locationLbl.isHidden = true
        }
        
        if let media = CoreDataManager.shared.getServiceFirstMedia(serviceId: Int(service.serviceId)) {
            if let imageData = media.mediaContent {
                    self.serviceImage.image = UIImage(data: imageData)
                }
        }
        
        dipalyServiceReview(serviceId :Int(service.serviceId))
        statusLabel.text = service.status
        if service.status == "Accepted" {
            statusLabel.textColor = UIColor.acceptedColor
        }else if service.status == "Rejected" {
            statusLabel.textColor = UIColor.rejectedColor
        }else{
            statusLabel.textColor = UIColor.pendingColor
        }
        
    }
    
    func dipalyServiceReview(serviceId : Int){
        let serviceReviewList = CoreDataManager.shared.getServiceReviewList(serviceId:serviceId)
        var reviewTotal = 0
        var rate = 0
        for review in serviceReviewList {
            reviewTotal += Int(review.rating)
        }
        if serviceReviewList.count > 0 {
            rate = reviewTotal / serviceReviewList.count
        }
        ratingLbl.text =  String(rate)
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
