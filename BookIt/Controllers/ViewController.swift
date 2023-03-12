//
//  ViewController.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-02-27.
//

import UIKit
import FacebookLogin
import CoreData
import GoogleSignIn
import AuthenticationServices

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isVendor = false
    private let biometricIDAuth = BiometricIDAuth()
    
    
    @IBOutlet weak var appleLoginBtn: ASAuthorizationAppleIDButton!
    @IBOutlet weak var vendorStatus: UISwitch!{
        didSet{
            vendorStatus.onTintColor = UIColor.switchBackgroundColor
            vendorStatus.tintColor = UIColor.switchBackgroundColor
            vendorStatus.subviews[0].subviews[0].backgroundColor = UIColor.switchBackgroundColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        appleLoginBtn.addTarget(self, action: #selector(handleLogInWithAppleID), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }


    @IBAction func continueGuest() {
        loadDashBoard(user: nil)
    }
    @IBAction func facebookLogin(_ sender: Any) {
        fetchFacebookFields();
    }
    
    @IBAction func vendorStatus(sender: UISwitch) {
        if (sender.isOn == true){
            isVendor = false
        }else{
            isVendor = true
        }
    }

    @IBAction func googleLogin(sender: Any) {
        getGoogleUser()
    }
    
    @IBAction func appleLogin(sender: Any) {
        handleLogInWithAppleID()
    }
    
//    @IBAction func signOut(sender: Any) {
//      GIDSignIn.sharedInstance.signOut()
//    let loginManager = LoginManager()
//    loginManager.logOut()
//    }
    
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
        if (checkUserInDB(user: user)){
            loadDashBoard(user: user)
            
        }else{
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as? EditProfileViewController {
//                nextViewController.loginUser = user
//                self.navigationController?.pushViewController(nextViewController, animated: true)
////                self.present(nextViewController , animated:true, completion:nil)
//            }
            
            if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController {
                if let navigator = navigationController {
                    viewController.loginUser = user
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
            UserDefaultsManager.shared.saveUserData(user: loginUser)
        }else{
            UserDefaultsManager.shared.removeUserLogin()
            UserDefaultsManager.shared.removeUserData()
        }
//
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController {
//            nextViewController.loginUser = user
//            self.navigationController?.pushViewController(nextViewController, animated: true)
////            self.present(nextViewController, animated:true, completion:nil)
//        }
        if (isVendor){
            if let viewController = UIStoryboard(name: "VendorDashBoard", bundle: nil).instantiateViewController(withIdentifier: "VendorDashBoardViewController") as? VendorDashBoardViewController {
                if let navigator = navigationController {
                    viewController.loginUser = user
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        else{
            let storyboard = UIStoryboard(name: "ClientDashBoard", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "ClientTabBarController")
            mainTabBarController.modalPresentationStyle = .fullScreen
            
            
            if let navigator = navigationController {
                //            viewController.loginUser = user
                navigator.pushViewController(mainTabBarController, animated: true)
            }
        }
        
//        if let viewController = UIStoryboard(name: "ClientDashBoard", bundle: nil).instantiateViewController(withIdentifier: "ClientTabBarController") as? ClientDashBoardViewController {
//            if let navigator = navigationController {
//                viewController.loginUser = user
//                navigator.pushViewController(viewController, animated: true)
//            }
//        }
    }
    
    func checkUserInDB(user : LoginUser) -> Bool{
        var success = false
        var entityName = "Client"
        if (isVendor){
            entityName = "Vendor"
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "email = %@ ", user.email)
        do {
            let user = try context.fetch(fetchRequest)
            if user.count == 1 {
                success = true
            }
        } catch {
            print(error)
        }
        return success
    }
}

// MARK: - Facebook Login
extension ViewController{
    func fetchFacebookFields(){
        
        LoginManager().logIn(permissions: ["email","public_profile"], from: nil) {
            (result, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let result = result else { return }
            if result.isCancelled { return }
            else {
                
                GraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name, email, birthday, gender, hometown"]).start() {
                    (connection, result, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if
                        let fields = result as? [String:Any],
                        let userID = fields["id"] as? String,
                        let firstName = fields["first_name"] as? String,
                        let lastName = fields["last_name"] as? String,
                        let email = fields["email"] as? String
                            
                    {
                        let facebookProfileUrl = "http://graph.facebook.com/\(userID)/picture?type=large"
                        print("firstName -> \(firstName)")
                        print("lastName -> \(lastName)")
                        print("email -> \(email)")
                        print("facebookProfileUrl -> \(facebookProfileUrl)")
                        
                        var loginUser = LoginUser(firstName: firstName, lastName: lastName, email: email, contactNumber: "",isVendor: self.isVendor)
                        if let url = URL(string: facebookProfileUrl) {
                            loginUser.picture = url
                        }
                        
                        self.checkUserAvailablility(user: loginUser)
                        
                    }
                }
            }
        }
    }
}

// MARK: - Google Login
extension ViewController{
    
    func getGoogleUser(){
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }

            let user = signInResult.user

            let emailAddress = user.profile?.email ?? ""

            let givenName = user.profile?.givenName ?? ""
            let familyName = user.profile?.familyName ?? ""

            let profilePicUrl = user.profile?.imageURL(withDimension: 320) ?? nil
            
            var loginUser = LoginUser(firstName: givenName, lastName: familyName, email: emailAddress, contactNumber: "",isVendor: self.isVendor)
            loginUser.picture = profilePicUrl
            self.checkUserAvailablility(user: loginUser)
        }
    }
}

// MARK: - Apple Login
extension ViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
     func handleLogInWithAppleID() {
         let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email,]
         
         let controller = ASAuthorizationController(authorizationRequests: [request])
         
         controller.delegate = self
         controller.presentationContextProvider = self
         
         controller.performRequests()
     }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
             return self.view.window!
      }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let lastName = appleIDCredential.fullName?.familyName ?? ""
            let email = appleIDCredential.email ?? ""
            let firstName = appleIDCredential.fullName?.givenName ?? ""
            var loginUser = LoginUser(firstName: firstName, lastName: lastName, email: email, contactNumber: "",isVendor: self.isVendor)
            loginUser.picture = nil
            self.checkUserAvailablility(user: loginUser)
            break
        default:
            break
        }
    }
}


extension ViewController {
    func bioMetricVerification(){
        biometricIDAuth.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message: canEvaluateError?.localizedDescription ?? "Face ID/Touch ID may not be configured", okActionTitle: "OK", view: self)
                return
            }
            
            biometricIDAuth.evaluate { [weak self] (success, error) in
                guard success else {
                    UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message: canEvaluateError?.localizedDescription ?? "Face ID/Touch ID may not be configured", okActionTitle: "OK", view: self ?? ViewController())
                    return
                }
                
              let loginUser =  UserDefaultsManager.shared.getUserData()
                self?.loadDashBoard(user: loginUser)
                UIAlertViewExtention.shared.showBasicAlertView(title: "Success", message:  "You have a free pass, now", okActionTitle: "OK", view: self ?? ViewController())
            }
        }
    }
}
