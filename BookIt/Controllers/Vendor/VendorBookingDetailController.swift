//
//  VendorBookingDetailController.swift
//  BookIt
//
//  Created by Tilak Acharya on 2023-03-17.
//

import Foundation
import UIKit

class VendorBookingDetailController: UIViewController{
    
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
        
        let viewController:VendorBookingConfirmationController = UIStoryboard(name: "VendorBookingConfirmation", bundle: nil).instantiateViewController(withIdentifier: "VendorBookingConfirmation") as? VendorBookingConfirmationController ?? VendorBookingConfirmationController()
        navigationController?.pushViewController(viewController, animated: true)
        
    }
}
