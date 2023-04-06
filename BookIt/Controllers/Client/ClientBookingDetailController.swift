//
//  ClientBookingDetailController.swift
//  BookIt
//
//  Created by Tilak Acharya on 2023-03-30.
//

import Foundation
import UIKit
import PayPalCheckout

class ClientBookingDetailController : NavigationBaseViewController{
    
    var booking:Booking?
    
    @IBOutlet weak var serviceImg: UIImageView!
    @IBOutlet weak var servicePriceLbl: UILabel!
    @IBOutlet weak var ratingAndDateLbl: UILabel!
    @IBOutlet weak var vendorNameLbl: UILabel!
    @IBOutlet weak var serviceTitleLbl: UILabel!
    @IBOutlet weak var bookingIdLbl: UILabel!
    @IBOutlet weak var locationDescLbl: UILabel!
    @IBOutlet weak var problemDescLbl: UILabel!
    @IBOutlet weak var totalPriceBtn: UIButton!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var serviceStatusBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    
    override func viewDidLoad() {
        loadDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        let titleLabel = UILabel()
        titleLabel.text = "Booking Details"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
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
        bookingIdLbl.text = "Booking number is #\(bookingId)"
        statusLbl.text = status
        problemDescLbl.text = booking?.problemDescription ?? "N/A"
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
                let controller = UIAlertController(title: "Confirm Cancellation", message: "Are you sure you want to cancel this service?", preferredStyle: .alert)

                let rescheduleAction = UIAlertAction(title: "Reschedule", style: .default) { (_) in
                    //Redirect to service booking page
                        if let clientBook = UIStoryboard(name: "ClientDashBoard", bundle: nil).instantiateViewController(withIdentifier: "ClientBookVendorViewController") as? ClientBookVendorViewController {
                            if let navigator = self.navigationController {
                                clientBook.selectedService = self.booking?.service
                                clientBook.selectedBooking = self.booking
                                clientBook.vendor = self.booking?.vendor
                                navigator.pushViewController(clientBook, animated: true)
                            }
                        }
                }

                let cancelAction = UIAlertAction(title: "No! Just Cancel", style: .destructive) { (_) in
                    // Handle Cancel action
                    if let booking = self.booking {
                        LoadingHudManager.shared.showSimpleHUD(title: "Cancelling...", view: self.view)
                            Task {
                                booking.status = ServiceStatus.CANCELLED.title
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

                let ignoreAction = UIAlertAction(title: "Ignore", style: .cancel) { (_) in
                    // Handle Ignore action
                    self.dismiss(animated: true)
                }

                controller.addAction(rescheduleAction)
                controller.addAction(cancelAction)
                controller.addAction(ignoreAction)
                return controller
            }()
            self.present(alertController, animated: true, completion: nil)
            
        case ServiceStatus.PENDING.title:
            makePayment()
            serviceStatusBtn.isHidden = false
            
        case ServiceStatus.COMPLETED.title:
            
            //if user has left review then just show button else redirect to rating page
            if let viewController = UIStoryboard(name: "Rating", bundle: nil).instantiateViewController(withIdentifier: "Rating") as? RatingController {
                if let navigator = navigationController {
                    viewController.client = booking?.client
                    viewController.vendor = booking?.vendor
                    viewController.service = booking?.service
                    viewController.vendorRating = true
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            
            
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
    
    private func makePayment(){
        let actionSheet = UIAlertController(title: "Payment Options", message: "Select the payment option you want tp proceed.", preferredStyle: .actionSheet)

        let actionCredit = UIAlertAction(title: "Credit/Debit", style: .default) { _ in
            self.paymentAPICall()
        }
        actionSheet.addAction(actionCredit)
        
        let actionApplePay = UIAlertAction(title: "Apple Pay", style: .default) { _ in
            self.paymentAPICall()
        }
        actionSheet.addAction(actionApplePay)

        let actionPayPal = UIAlertAction(title: "PayPal", style: .default) { _ in
            self.triggerPayPalCheckout(price:self.priceLbl.text ?? "0")
        }
        actionSheet.addAction(actionPayPal)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(cancelAction)

        present(actionSheet, animated: true)
    }
}

// MARK: - Service Calls
extension ClientBookingDetailController {
    
    //User payment service call
    func paymentAPICall()
    {
        let param = UserPaymentParam(clientEmail: booking?.client?.email ?? "", bookingId: String(describing:booking?.bookingId), vendorEmail: booking?.vendor?.email ?? "")
        let urlPath: String = "user/signin"
        
        NetworkManager.shared.makePayment(urlStr: urlPath, postData: param.toJSON()) { (success, rsponse) in
            if success == true
            {DispatchQueue.main.async {
                print(rsponse?.userEmail)
                if let booking = self.booking {
                    booking.status = ServiceStatus.IN_PROGRESS.title
                    self.saveAllContextCoreData()
                }
                //go to home.
            }
 
            }else{
                UIAlertViewExtention.shared.showBasicAlertView(title: "Payment Failed", message: "Sonmething went wrong please try again.", okActionTitle: "OK", view: self)
            }
        }
    }
}

extension ClientBookingDetailController{
    func triggerPayPalCheckout(price : String) {
        Checkout.start(
            createOrder: { createOrderAction in

                let amount = PurchaseUnit.Amount(currencyCode: .cad, value: price)
                let purchaseUnit = PurchaseUnit(amount: amount)
                let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])

                createOrderAction.create(order: order)

            }, onApprove: { approval in

                approval.actions.capture { (response, error) in
                    self.paymentAPICall()
                    print("Order successfully captured: \(response?.data)")
                }

            }, onCancel: {

                // Optionally use this closure to respond to the user canceling the paysheet

            }, onError: { error in

                // Optionally use this closure to respond to the user experiencing an error in
                // the payment experience

            }
        )
    }
    
//    private func configurePayPalCheckout() {
//            Checkout.setCreateOrderCallback { action in
//                let amount = PurchaseUnit.Amount(currencyCode: .usd, value: "10.00")
//                let purchaseUnit = PurchaseUnit(amount: amount)
//                let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
//
//                action.create(order: order)
//            }
//            Checkout.setOnApproveCallback { approval in
//                approval.actions.capture { response, error in
//                    print("Order successfully captured: \(response?.data)")
//                }
//            }
//        }

}
