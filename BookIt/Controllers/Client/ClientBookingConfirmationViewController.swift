//
//  ClientBookingConfirmationViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-04-09.
//

import UIKit

class ClientBookingConfirmationViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    var titleContent: String?
    var messageContent: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = titleContent
        lblMessage.text = messageContent
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func gotoHistoryBooking(_ sender: Any) {
        if let navigator = self.navigationController {
            var targetVC : UITabBarController?
            targetVC = navigationController?.viewControllers.first(where: {$0 is UITabBarController}) as? UITabBarController
            if let targetVC = targetVC {
                targetVC.selectedIndex = 2
                navigationController?.popToViewController(targetVC, animated: true)
            }
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
