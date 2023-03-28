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
    
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetails()
    }
    
    func loadDetails(){
        
        guard let service = booking?.service,
              let client = booking?.client,
              let payment = booking?.payment,
              let vendor = booking?.vendor else {
            return
        }
        
        bookingIdLbl.text = "Booking number is \(booking)"
        serviceNameLbl.text = service.serviceTitle
        customerNameLbl.text = "\(client.firstName) + \(client.lastName)"
        
    }
    
    @IBAction func acceptBooking(_ sender: Any) {
        
        if let booking = booking{
            LoadingHudManager.shared.showSimpleHUD(title: "Accepting...", view: self.view)
                Task {
                    booking.status = "Accepted"
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
    
    
    @IBAction func rejectBooking(_ sender: Any) {
        
        if let booking = booking{
            LoadingHudManager.shared.showSimpleHUD(title: "Rejecting...", view: self.view)
                Task {
                    booking.status = "Rejected"
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
