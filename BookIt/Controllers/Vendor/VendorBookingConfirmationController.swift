//
//  VendorBookingConfirmationController.swift
//  BookIt
//
//  Created by Tilak Acharya on 2023-03-17.
//

import Foundation
import UIKit

class VendorBookingConfirmationController : UIViewController{
    
    @IBAction func goToDashboard(_ sender: Any) {
        if let navigator = self.navigationController {
            navigator.popViewController(animated: true)
        }
    }
}
