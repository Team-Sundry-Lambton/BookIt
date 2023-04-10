//
//  ClientBookingConfirmationViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-04-09.
//

import UIKit

class ClientBookingConfirmationViewController: UIViewController {
    
    var delegate: ClientBookVendorProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func gotoHistoryBooking(_ sender: Any) {
        if let navigator = self.navigationController {
            delegate?.backFromBookingComfirm()
            navigator.popViewController(animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
