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
import JGProgressHUD

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
        NetworkMonitor.shared.setObserve(viewController: self)
    }

    @IBAction func vendorByPass(_ sender: Any) {
        let lastName = "Admin"
        let email = "admin@gmail.com"
        let firstName = "Admin"
        var loginUser = LoginUser(firstName: firstName, lastName: lastName, email: email, contactNumber: "123456789",isVendor: self.isVendor)
        loginUser.picture = nil
        self.checkUserAvailablility(user: loginUser)
    }
    
    
    @IBAction func continueGuest() {
        loadDashBoard(user: nil)
    }
    @IBAction func facebookLogin(_ sender: Any) {
        fetchFacebookFields();
    }
    
    @IBAction func vendorStatus(sender: UISwitch) {
        if (sender.isOn == true){
            isVendor = true
        }else{
            isVendor = false
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
        if (CoreDataManager.shared.checkUserInDB(user: user,isVendor: isVendor)){
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
        LoadingHudManager.shared.showSimpleHUD(title: "Downloading...", view: self.view)
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

extension ViewController {
    func openDashBoard(user : LoginUser?) {
        self.loadDashBoard(user: user)
    }
}
