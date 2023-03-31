//
//  VendorBookingDetailController.swift
//  BookIt
//
//  Created by Tilak Acharya on 2023-03-17.
//

import Foundation
import UIKit

class VendorBookingDetailController: UIViewController{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var booking:Booking?
    var service:Service?
    
    @IBOutlet weak var bookingIdLbl: UILabel!
    
    @IBOutlet weak var serviceNameLbl: UILabel!
    @IBOutlet weak var servicePriceLbl: UILabel!
    @IBOutlet weak var customerLocationLbl: UILabel!
    @IBOutlet weak var bookingDateLbl: UILabel!
    @IBOutlet weak var customerNameLbl: UILabel!
    @IBOutlet weak var viewServiceDetailsBtn: UIButton!
    @IBOutlet weak var serviceImg: UIImageView!
    
    @IBOutlet weak var bookingLocationLbl: UILabel!
    @IBOutlet weak var bookingCommentLbl: UILabel!
    
    @IBOutlet weak var orderPriceLbl: UILabel!
    @IBOutlet weak var applicationFeePriceLbl: UILabel!
    @IBOutlet weak var totalOrderPriceLbl: UILabel!
    @IBOutlet weak var deliveryPriceLbl: UILabel!
    
    @IBOutlet weak var totalIncomeBtn: UIButton!
    
    @IBOutlet weak var serviceStatusBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetails()
    }
    
    func loadDetails(){
        
        guard
            let service = booking?.service
                ,let client = booking?.client
        else {
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
        
        serviceNameLbl.text = service.serviceTitle
        if let media = CoreDataManager.shared.getServiceFirstMedia(serviceId: Int(service.serviceId)) {
            if let imageData = media.mediaContent {
                    self.serviceImg.image = UIImage(data: imageData)
                }
        }
        
        customerNameLbl.text = "\(String(describing:client.firstName ?? "")) \(String(describing:client.lastName ?? ""))"
        bookingDateLbl.text = booking?.date?.dateAndTimetoString()
        customerLocationLbl.text =  client.address?.address ?? "N/A"
        
        if let price = service.price, let type = service.priceType {
            servicePriceLbl.text = "$ " + price + " / " + type
        }
        
        bookingLocationLbl.text = status
        let price:Double = Double(service.price ?? "") ?? 0.0
        let discount = 0.0
        let totalPrice = price - discount
        let applicationFee = 0.1*price
        let earningAmount = totalPrice - applicationFee
        orderPriceLbl.text = "$\(price)"
        deliveryPriceLbl.text = "$\(discount)"
        totalOrderPriceLbl.text = "$\(totalPrice)"
        applicationFeePriceLbl.text = "$\(applicationFee)"
        
        totalIncomeBtn.setTitle("Total Income : $\(earningAmount)", for: .normal)
    
        switch status {
            case ServiceStatus.NEW.title:
                acceptBtn.isHidden = false
                declineBtn.isHidden = false
                serviceStatusBtn.isHidden = true
            case ServiceStatus.PENDING.title:
            acceptBtn.isHidden = true
            declineBtn.isHidden = true
            serviceStatusBtn.isHidden = false
            serviceStatusBtn.isEnabled = false
            serviceStatusBtn.setTitle(ServiceStatus.PENDING.nextStep.forVendor, for: .normal)
            case ServiceStatus.IN_PROGRESS.title:
            acceptBtn.isHidden = true
            declineBtn.isHidden = true
            serviceStatusBtn.isHidden = false
            serviceStatusBtn.isEnabled = true
            serviceStatusBtn.setTitle(ServiceStatus.IN_PROGRESS.nextStep.forVendor, for: .normal)
            case ServiceStatus.COMPLETED.title:
            acceptBtn.isHidden = true
            declineBtn.isHidden = true
            serviceStatusBtn.isHidden = false
            serviceStatusBtn.isEnabled = false
            serviceStatusBtn.setTitle(ServiceStatus.COMPLETED.nextStep.forVendor, for: .normal)
            case ServiceStatus.REJECTED.title:
            acceptBtn.isHidden = true
            declineBtn.isHidden = true
            serviceStatusBtn.isHidden = false
            serviceStatusBtn.isEnabled = false
            serviceStatusBtn.setTitle(ServiceStatus.REJECTED.nextStep.forVendor, for: .normal)
            case ServiceStatus.CANCELLED.title:
            acceptBtn.isHidden = true
            declineBtn.isHidden = true
            serviceStatusBtn.isHidden = false
            serviceStatusBtn.isEnabled = false
            serviceStatusBtn.setTitle(ServiceStatus.CANCELLED.nextStep.forVendor, for: .normal)
            default:
            acceptBtn.isHidden = true
            declineBtn.isHidden = true
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
    
    @IBAction func acceptBooking(_ sender: Any) {
        
        if let booking = booking{
            LoadingHudManager.shared.showSimpleHUD(title: "Accepting...", view: self.view)
                Task {
                    booking.status = ServiceStatus.PENDING.title
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
                                    let storyboard = UIStoryboard(name: "VendorBookingConfirmation", bundle: nil)
                                    let mainTabBarController = storyboard.instantiateViewController(identifier: "VendorBookingConfirmation")
                                    mainTabBarController.modalPresentationStyle = .fullScreen
                                    if let navigator = strongSelf.navigationController {
                                        navigator.pushViewController(mainTabBarController, animated: true)
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
    
    private func saveAllContextCoreData() {
        do {
            try context.save()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func performNextStep(_ sender: Any) {
        switch self.booking?.status {
            
        case ServiceStatus.IN_PROGRESS.title:
            
            if let booking = booking {
                LoadingHudManager.shared.showSimpleHUD(title: "Marking as complete...", view: self.view)
                Task {
                    booking.status = ServiceStatus.COMPLETED.title
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
            
        case ServiceStatus.COMPLETED.title:
            //goto review page
            serviceStatusBtn.isEnabled = true
        default:
            //nothing
            serviceStatusBtn.isEnabled = false
        }
        
    }
    
    
    @IBAction func rejectBooking(_ sender: Any) {
        
        if let booking = booking{
            LoadingHudManager.shared.showSimpleHUD(title: "Rejecting...", view: self.view)
                Task {
                    booking.status = ServiceStatus.REJECTED.title
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
    
    
}
