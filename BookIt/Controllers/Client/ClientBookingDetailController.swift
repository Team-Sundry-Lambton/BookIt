//
//  ClientBookingDetailController.swift
//  BookIt
//
//  Created by Tilak Acharya on 2023-03-30.
//

import Foundation
import UIKit


class ClientBookingDetailController : UIViewController{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var booking:Booking?
    
    @IBOutlet weak var serviceImg: UIImageView!
    @IBOutlet weak var servicePriceLbl: UILabel!
    @IBOutlet weak var ratingAndDateLbl: UILabel!
    @IBOutlet weak var vendorNameLbl: UILabel!
    @IBOutlet weak var serviceTitleLbl: UILabel!
    @IBOutlet weak var bookingIdLbl: UILabel!
    @IBOutlet weak var locationDescLbl: UILabel!
    @IBOutlet weak var statusDescLbl: UILabel!
    @IBOutlet weak var totalPriceBtn: UIButton!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var serviceStatusBtn: UIButton!
    
    override func viewDidLoad() {
        loadDetails()
    }
    
    func loadDetails(){
        
        guard
            let service = booking?.service
                ,let vendor = booking?.vendor
                ,let client = booking?.client
        else{
            return
        }
        
        let status = String(describing: booking?.status ?? "")
        
        var bookingId :String
        if let id = booking?.bookingId{
            bookingId = String(describing:id)
        }
        else{
            bookingId = "N/A"
        }
        bookingIdLbl.text = "Booking number is \(bookingId)"
        
        serviceTitleLbl.text = service.serviceTitle
        if let media = CoreDataManager.shared.getServiceFirstMedia(serviceId: Int(service.serviceId)) {
            if let imageData = media.mediaContent {
                    self.serviceImg.image = UIImage(data: imageData)
                }
        }
        vendorNameLbl.text = "\(String(describing:vendor.firstName ?? "")) \(String(describing:vendor.lastName ?? ""))"
        
        let serviceReviewList = CoreDataManager.shared.getServiceReviewList(serviceId:Int(service.serviceId))
        var reviewTotal = 0
        var rate = 0
        for review in serviceReviewList {
            reviewTotal += Int(review.rating)
        }
        if serviceReviewList.count > 0 {
            rate = reviewTotal / serviceReviewList.count
        }
        ratingAndDateLbl.text =  "\(String(rate)) | \(String(describing: booking?.date?.dateAndTimetoString() ?? ""))"
        
        
        if let price = service.price, let type = service.priceType {
            servicePriceLbl.text = "$ " + price + " / " + type
        }
        
        statusDescLbl.text = status
        locationDescLbl.text =  client.address?.address ?? "N/A"
        
        let price:Double = Double(service.price ?? "") ?? 0.0
        let discount = 0.0
        let totalPrice = price - discount
        priceLbl.text = "$\(price)"
        discountLbl.text = "$\(discount)"
        
        totalPriceBtn.setTitle("Total Price : $\(totalPrice)", for: .normal)
        
        updateButton(status: status)
    }
    
    func updateButton(status:String){
        switch status {
            case ServiceStatus.NEW.title:
            serviceStatusBtn.setTitle(ServiceStatus.NEW.nextStep.forClient, for: .normal)
            serviceStatusBtn.tintColor = UIColor(named:"main_orange")
            
            case ServiceStatus.PENDING.title:
            serviceStatusBtn.setTitle(ServiceStatus.PENDING.nextStep.forClient, for: .normal)
            serviceStatusBtn.tintColor = UIColor(named:"main_red")
            
            case ServiceStatus.IN_PROGRESS.title:
            serviceStatusBtn.setTitle(ServiceStatus.IN_PROGRESS.nextStep.forClient, for: .normal)
            serviceStatusBtn.tintColor = UIColor(named:"main_green")
            
            case ServiceStatus.COMPLETED.title:
            serviceStatusBtn.setTitle(ServiceStatus.COMPLETED.nextStep.forClient, for: .normal)
            serviceStatusBtn.tintColor = UIColor(named:"main_blue")
            
            case ServiceStatus.REJECTED.title:
            serviceStatusBtn.setTitle(ServiceStatus.REJECTED.nextStep.forClient, for: .normal)
            serviceStatusBtn.tintColor = UIColor(named:"main_dark_grey")
            
            case ServiceStatus.CANCELLED.title:
            serviceStatusBtn.setTitle(ServiceStatus.CANCELLED.nextStep.forClient, for: .normal)
            serviceStatusBtn.tintColor = UIColor(named:"main_dark_grey")
            
            default:
            serviceStatusBtn.isHidden = true
        }
    }
    
    
    
    
    @IBAction func viewServiceDetail(_ sender: Any) {
        if let service = booking?.service{
            if let viewController = UIStoryboard(name: "ServiceDetail", bundle: nil).instantiateViewController(withIdentifier: "ClientServiceDetailViewController") as? ClientServiceDetailViewController {
                if let navigator = navigationController {
                    viewController.selectedService = service
                    navigator.pushViewController(viewController, animated: true)
                    
                }
            }
        }
    }
    
    @IBAction func nextStepAction(_ sender: Any) {
        
        switch self.booking?.status {
            
        case ServiceStatus.NEW.title:
            
            let alertController: UIAlertController = {
                
                let controller = UIAlertController(title: "Cancel booking", message: "Are you sure ?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: .default){
                    UIAlertAction in
                    
                    if let booking = self.booking {
                        LoadingHudManager.shared.showSimpleHUD(title: "Cancelling...", view: self.view)
                            Task {
                                booking.status = ServiceStatus.CANCELLED.title
                                await
                                InitialDataDownloadManager.shared.updateBookingData(booking:booking){[weak self] status in
                                    DispatchQueue.main.async {
                                        LoadingHudManager.shared.dissmissHud()
                                        guard let strongSelf = self else {
                                            return
                                        }
                                        if let status = status {
                                            if status {
                                                strongSelf.saveAllContextCoreData()
                                                //go back
                                                if let navigator = self?.navigationController {
                                                    navigator.popViewController(animated: true)
                                                }
                                            }else{
                                                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: strongSelf)
                                            }
                                        }
                                    }
                                }
                            }
                    }
                    
                }
                let cancelAction = UIAlertAction(title: "No", style: .cancel){
                    UIAlertAction in
                    self.dismiss(animated: true)
                }
                controller.addAction(okAction)
                controller.addAction(cancelAction)
                return controller
            }()
            self.present(alertController, animated: true)
            
        case ServiceStatus.PENDING.title:
            //make a payment
            serviceStatusBtn.isHidden = false
            
        case ServiceStatus.COMPLETED.title:
            
            //if user has left review then just show button else redirect to rating page
            serviceStatusBtn.isHidden = false
            
        default:
            print(booking?.status)
        }
        
    }
    
    private func saveAllContextCoreData() {
        do {
            try context.save()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
}
