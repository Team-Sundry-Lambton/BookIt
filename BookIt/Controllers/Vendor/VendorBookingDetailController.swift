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
    
    var booking:Booking! = nil
    var client:Client! = nil
    var vendor:Vendor! = nil
    var service:Service! = nil
    
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
    }
    
    func loadDetails(model:Booking){
        
        bookingIdLbl.text = "Booking number is \(model)"
        
        guard let service = service,
        let client = client,
        let vendor = vendor else {
            return
        }
        serviceNameLbl.text = service.serviceTitle
        
        customerNameLbl.text = "\(client.firstName) + \(client.lastName)"
        
//        bookingDateLbl.text = "\(booking.date)"
        
//        customerLocationLbl.text = service.
        
        
        
        
    }
    
    @IBAction func acceptBooking(_ sender: Any) {
        
        if let booking = booking{
            LoadingHudManager.shared.showSimpleHUD(title: "Accepting...", view: self.view)
                Task {
                    booking.status = "Accepted"
                    await
                    InitialDataDownloadManager.shared.updateBookingData(booking:booking){ status in
                        DispatchQueue.main.async {
                            LoadingHudManager.shared.dissmissHud()
                            if let status = status {
                                if status {
                                    self.saveAllContextCoreData()
                                    let viewController:VendorBookingConfirmationController = UIStoryboard(name: "VendorBookingConfirmation", bundle: nil).instantiateViewController(withIdentifier: "VendorBookingConfirmation") as? VendorBookingConfirmationController ?? VendorBookingConfirmationController()
                                    self.navigationController?.pushViewController(viewController, animated: true)
                                }else{
                                    UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
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
                    InitialDataDownloadManager.shared.updateBookingData(booking:booking){ status in
                        DispatchQueue.main.async {
                            LoadingHudManager.shared.dissmissHud()
                            if let status = status {
                                if status {
                                    self.saveAllContextCoreData()
                                    //go back
                                }else{
                                    UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
                                }
                            }
                        }
                    }
                }
        }
        
    }
    
    
}
