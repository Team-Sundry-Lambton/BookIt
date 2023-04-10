//
//  ClientBookingConfirmationViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-04-09.
//

import UIKit

class ClientBookingConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func gotoHistoryBooking(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ClientDashBoard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ClientBookingViewController") as! ClientBookingViewController
        vc.modalPresentationStyle = .fullScreen
        if let navigator = self.navigationController {
            navigator.pushViewController(vc, animated: true)
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
