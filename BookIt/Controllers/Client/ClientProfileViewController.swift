//
//  ClientProfileViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-09.
//

import UIKit

class ClientProfileViewController: UIViewController {

    @IBOutlet weak var faceIDStatus: UISwitch!
    
    @IBOutlet weak var notificationStatus: UISwitch!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var logoutTextLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBorder()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        if (UserDefaultsManager.shared.getUserLogin()){
            logoutTextLbl.text = "Logout"
            let user =  UserDefaultsManager.shared.getUserData()
            nameLbl.text = user.firstName + " " + user.lastName
            emailLbl.text = user.email
            if let path = user.picture{
                imageView.load(url: path)
            }
        }else{
            nameLbl.text = ""
            emailLbl.text = ""
            logoutTextLbl.text = "Register"
        }
    }
    
    func addBorder() {
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 5
        imageView.layer.cornerRadius = imageView.frame.height / 2
    }
    
    @IBAction func faceIDStatus(sender: UISwitch) {
        if (UserDefaultsManager.shared.getUserLogin()){
            if (sender.isOn == true){
                UserDefaultsManager.shared.setFaceIdEnable(status: true)
            }else{
                UserDefaultsManager.shared.setFaceIdEnable(status: false)
            }
        }
        else{
            sender.isOn = false
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first.", okActionTitle: "OK", view: self)
        }
    }
    
    @IBAction func notificationStatus(sender: UISwitch) {
        if (UserDefaultsManager.shared.getUserLogin()){
            if (sender.isOn == true){
                UserDefaultsManager.shared.setNotificationEnable(status: true)
            }else{
                UserDefaultsManager.shared.setNotificationEnable(status: false)
            }
        }else{
            sender.isOn = false
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first.", okActionTitle: "OK", view: self)
        }
    }

    @IBAction func loadProfileEditPage() {
        if (UserDefaultsManager.shared.getUserLogin()){
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController {
                if let navigator = navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }else{
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Please regiter first.", okActionTitle: "OK", view: self)
       }
    }
    
    @IBAction func logOut() {
        UserDefaultsManager.shared.removeUserLogin()
        UserDefaultsManager.shared.removeUserData()
        
        if let navigator = navigationController {
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
