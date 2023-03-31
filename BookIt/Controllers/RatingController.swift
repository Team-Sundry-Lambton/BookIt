//
//  RatingController.swift
//  BookIt
//
//  Created by Tilak Acharya on 2023-03-31.
//

import Foundation
import UIKit
import Cosmos

class RatingController : UIViewController{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewTextArea: UITextView!
    
    var client : Client?
    var vendor : Vendor?
    var service : Service?
    var vendorRating: Bool = true
    
    @IBAction func submitReview(_ sender: Any) {
        let rating = rating.rating
        let review = reviewTextArea.text ?? ""
        
        let vendorReview = VendorReview(context: context)
        vendorReview.rating = Int16(rating)
        vendorReview.comment = review
        vendorReview.client = client
        vendorReview.vendor = vendor
        vendorReview.service = service
        vendorReview.vendorRating = vendorRating
        
        LoadingHudManager.shared.showSimpleHUD(title: "Uploading your rating...", view: self.view)
            Task {
                await InitialDataDownloadManager.shared.addVendorReviewData(vendorReview:vendorReview){[weak self] status in
                    DispatchQueue.main.async {
                        LoadingHudManager.shared.dissmissHud()
                        guard let strongSelf = self else {
                            return
                        }
                        if let status = status {
                            if status {
                                strongSelf.saveAllContextCoreData()
                            }else{
                                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: strongSelf)
                            }
                        }
                    }
                }
            }
    }
    
    private func saveAllContextCoreData() {
        do {
            try context.save()
            clearFieldAndNavigateBack()
            showAlert()
        } catch {
            print("Error saving the data \(error.localizedDescription)")
        }
    }
    
    private func clearFieldAndNavigateBack(){
        rating.rating = 0
        reviewTextArea.text = ""
    }
    
    func showAlert(){
        let alertController: UIAlertController = {
            let controller = UIAlertController(title: "Success", message: "Successfully rated.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default){
                UIAlertAction in
                if let navigator = self.navigationController {
                    navigator.popViewController(animated: true)
                }else{
                    self.dismiss(animated: true)
                }
            }
            controller.addAction(okAction)
            return controller
        }()
        self.present(alertController, animated: true)
    }
    
    @IBAction func maybeLater(_ sender: Any) {
        if let navigator = self.navigationController {
            navigator.popViewController(animated: true)
        }
    }
}
