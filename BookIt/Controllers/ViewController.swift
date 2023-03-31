//
//  ViewController.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-02-27.
//

import UIKit
import AuthenticationServices
import JGProgressHUD

class ViewController: UIViewController {
      
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isVendor = false
    private let biometricIDAuth = BiometricIDAuth()

    @IBOutlet weak var vendorStatus: UISegmentedControl!{
        didSet{
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appThemeColor]
            vendorStatus.setTitleTextAttributes(titleTextAttributes, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkMonitor.shared.setObserve(viewController: self)
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            if let navigator = navigationController {
                viewController.isVendor = isVendor
                navigator.pushViewController(viewController, animated: true)
            }
        }
      
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController {
            if let navigator = navigationController {
                viewController.isVendor = isVendor
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func continueGuest() {
        loadDashBoard(user: nil)
    }
   
    
    @IBAction func vendorStatus(_ sender: Any) {
        switch vendorStatus.selectedSegmentIndex {
        case 0:
            isVendor = false
        case 1 :
            isVendor = true
        default:
            isVendor = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        if ( UserDefaultsManager.shared.getUserLogin()){
            if (  UserDefaultsManager.shared.getFaceIdEnable()){
                bioMetricVerification()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    func checkUserAvailablility(user : LoginUser){
        if (CoreDataManager.shared.checkUserInDB(email: user.email,isVendor: isVendor)){
            loadDashBoard(user: user)
            
        }else{
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController {
                if let navigator = navigationController {
                    viewController.loginUser = user
                    viewController.delegate = self
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    func loadDashBoard(user : LoginUser?){
        
        UserDefaultsManager.shared.setUserLogin(status: true)
        UserDefaultsManager.shared.setIsVendor(status: isVendor)
        if let loginUser = user {
            UserDefaultsManager.shared.setUserLogin(status: true)
            setUser(user: loginUser)
        }else{
            UserDefaultsManager.shared.removeUserLogin()
            UserDefaultsManager.shared.removeUserData()
        }
        LoadingHudManager.shared.showSimpleHUD(title: "Loading...", view: self.view)
        Task {
            await InitialDataDownloadManager.shared.downloadAllData{
                DispatchQueue.main.async {
                    LoadingHudManager.shared.dissmissHud()
                    if (self.isVendor){
                        let storyboard = UIStoryboard(name: "VendorDashBoard", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "VendorTabBarController")
                        mainTabBarController.modalPresentationStyle = .fullScreen
                        if let navigator = self.navigationController {
                            navigator.pushViewController(mainTabBarController, animated: true)
                        }
                    }
                    else{
                        let storyboard = UIStoryboard(name: "ClientDashBoard", bundle: nil)
                        let mainTabBarController = storyboard.instantiateViewController(identifier: "ClientTabBarController")
                        mainTabBarController.modalPresentationStyle = .fullScreen
                        if let navigator = self.navigationController {
                            //            viewController.loginUser = user
                            navigator.pushViewController(mainTabBarController, animated: true)
                        }
                    }
                }
            }
        }
        
    }
    
    func setUser(user : LoginUser){
        if (isVendor){
            if let user = CoreDataManager.shared.getVendor(email: user.email) {
                
                let loginUser = LoginUser(firstName: user.firstName ?? "", lastName: user.lastName ?? "", email: user.email ?? "", contactNumber: user.contactNumber ?? "",isVendor: isVendor)
                UserDefaultsManager.shared.saveUserData(user: loginUser)
                
            }
        }else{
            if let user = CoreDataManager.shared.getClient(email: user.email){
                let loginUser = LoginUser(firstName: user.firstName ?? "", lastName: user.lastName ?? "", email: user.email ?? "", contactNumber: user.contactNumber ?? "",isVendor: isVendor)
                UserDefaultsManager.shared.saveUserData(user: loginUser)
            }
        }
    }
}


extension ViewController {
    func bioMetricVerification(){
        biometricIDAuth.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                return
            }
            
            biometricIDAuth.evaluate { [weak self] (success, error) in
                guard success else {
                    return
                }
                
                let loginUser =  UserDefaultsManager.shared.getUserData()
                self?.loadDashBoard(user: loginUser)
                UIAlertViewExtention.shared.showBasicAlertView(title: "Success", message:  "You have a free pass, now", okActionTitle: "OK", view: self ?? ViewController())
            }
        }
    }
}
