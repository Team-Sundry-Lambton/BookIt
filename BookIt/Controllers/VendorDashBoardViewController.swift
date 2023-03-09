//
//  VendorDashBoardViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-08.
//

import UIKit

class VendorDashBoardViewController: UIViewController {

    var loginUser : LoginUser?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loadPostService(){
        if let viewController = UIStoryboard(name: "PostService", bundle: nil).instantiateViewController(withIdentifier: "PostServiceViewController") as? PostServiceViewController {
            if let navigator = navigationController {
                viewController.loginUser = loginUser
                navigator.pushViewController(viewController, animated: true)
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
