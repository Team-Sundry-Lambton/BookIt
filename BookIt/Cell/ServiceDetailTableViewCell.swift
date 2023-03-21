//
//  ServiceDetailTableViewCell.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-11.
//

import UIKit
import CoreData

class ServiceDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var pricetLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    
    var selectedLocation: Address?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func configureCell(service: Service) {
        getLocationData(serviceId: Int(service.serviceId))
        if let title = service.serviceTitle {
            titleLbl.text = title
        }
        if let description = service.serviceDescription {
            descriptionLbl.text = description
        }
        if let price = service.price, let type = service.priceType {
            pricetLbl.text = "$ " + price + " / " + type
        }
        if let address =  service.address {
            locationLbl.isHidden = false
            locationLbl.text =  address.address
        }else{
            locationLbl.isHidden = true
        }
        
        if let user =  service.parent_Vendor {
            if let firstName = user.firstName, let lastName = user.lastName {
                nameLbl.isHidden = false
                nameLbl.text = firstName + " " + lastName
            }else{
                nameLbl.isHidden = true
            }
        }else{
            nameLbl.isHidden = true
        }
        
        if let media = CoreDataManager.shared.getServiceFirstMedia(serviceTitle: service.serviceTitle ?? "") {
            if let imageData = media.mediaContent {
                    self.serviceImage.image = UIImage(data: imageData)
                }
        }
        
//        if let imageData = mediaList[0].image {
//            self.serviceImage.image = UIImage(data: imageData)
//        }
    }
    
    private func getLocationData(serviceId : Int) {
        let request: NSFetchRequest<Address> = Address.fetchRequest()
        let folderPredicate = NSPredicate(format: "parentService.serviceId=%@", serviceId)
        request.predicate = folderPredicate
        do {
            let location = try context.fetch(request)
            selectedLocation = location.first
        } catch {
            print("Error loading location data \(error.localizedDescription)")
        }
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
