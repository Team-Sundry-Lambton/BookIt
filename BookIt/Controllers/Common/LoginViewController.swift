//
//  LoginViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-26.
//

import UIKit
import FacebookLogin
import GoogleSignIn
import AuthenticationServices

class LoginViewController: NavigationBaseViewController {
    
    var isVendor = false
    private let biometricIDAuth = BiometricIDAuth()
    var loginSuccess = false
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkMonitor.shared.setObserve(viewController: self)
        
        let signupText = NSMutableAttributedString(string: "Don't have an account? Register Now")
        signupText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.appThemeColor, range: NSRange(location: 22,length: 13))
        signUpBtn.setAttributedTitle(signupText, for: .normal)
        
        //MARK: dismiss keyboard        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    @IBAction func loginBtnClicked() {
        if emailTxt.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Email cannot be empty.", okActionTitle: "OK", view: self)
            return
        }else if passwordTxt.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Password cannot be empty.", okActionTitle: "OK", view: self)
            return
        }else{
            redirectUser(email: emailTxt.text ?? "")
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
    
    @IBAction func facebookLogin(_ sender: Any) {
        fetchFacebookFields();
    }
    
    @IBAction func googleLogin(sender: Any) {
        getGoogleUser()
    }
    
    @IBAction func appleLogin(sender: Any) {
        handleLogInWithAppleID()
    }
    
    @IBAction func forgotPassword() {
        UIAlertViewExtention.shared.showBasicAlertView(title: "Forgot Password?",message: "Please contact us at teamsundry@gmail.com to send resent password link.", okActionTitle: "OK", view: self)
    }
    
    func redirectUser(email : String){
        checkUserAvailablility(email : email){ status in
            DispatchQueue.main.async {
                if status == true {
                    var password = ""
                    if (self.isVendor){
                        if let vendor = CoreDataManager.shared.getVendor(email: email){
                            self.loginUser = LoginUser(firstName: vendor.firstName ?? "", lastName: vendor.lastName ?? "", email: vendor.email ?? "", contactNumber: vendor.contactNumber ?? "",isVendor: self.isVendor)
                            if let pw = vendor.password {
                                if pw.count > 0 {
                                    password = dencryptString(encyrptedString:pw)
                                }
                            }
                        }
                    }else{
                        if let client = CoreDataManager.shared.getClient(email: email){
                            self.loginUser = LoginUser(firstName: client.firstName ?? "", lastName: client.lastName ?? "", email: client.email ?? "", contactNumber: client.contactNumber ?? "",isVendor: self.isVendor)
                            if let pw = client.password {
                                if pw.count > 0 {
                                    password = dencryptString(encyrptedString:pw)
                                }
                            }
                        }
                    }
                    if let enterdPassword = self.passwordTxt.text {
                        if password == enterdPassword{
                            self.loadDashBoard(user: self.loginUser)
                        }else{
                            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Password miss match.", okActionTitle: "OK", view: self)
                            LoadingHudManager.shared.dissmissHud()
                        }
                    }
                }else{
                    UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "User not found please register first.", okActionTitle: "OK", view: self)
                }
            }
        }
    }
    
    func checkUserAvailablility(email : String,completion: @escaping (_ status: Bool?) -> Void){
         let dbCheck = CoreDataManager.shared.checkUserInDB(email: email,isVendor: isVendor)
        if !dbCheck {
            LoadingHudManager.shared.showSimpleHUD(title: "Validating...", view: self.view)
            InitialDataDownloadManager.shared.chedkUserData(email: email ,isVendor: isVendor ){ [weak self] status in
                DispatchQueue.main.async {
                    guard let strongSelf = self else {
                        return
                    }
                    if let user = status {
                        if user{
                            completion(true)
                        }else{
                            completion(false)
                        }
                    }
                }
            }
        }else{
            completion(true)
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
       var loginUser :LoginUser?
        if (isVendor){
            if let user = CoreDataManager.shared.getVendor(email: user.email) {
                
                loginUser = LoginUser(firstName: user.firstName ?? "", lastName: user.lastName ?? "", email: user.email ?? "", contactNumber: user.contactNumber ?? "",isVendor: isVendor)
                
            }
        }else{
            if let user = CoreDataManager.shared.getClient(email: user.email){
                loginUser = LoginUser(firstName: user.firstName ?? "", lastName: user.lastName ?? "", email: user.email ?? "", contactNumber: user.contactNumber ?? "",isVendor: isVendor)
            }
        }
        if let user = loginUser {
            UserDefaultsManager.shared.saveUserData(user: user)
        }else{
            UserDefaultsManager.shared.saveUserData(user: user)
        }
    }
}



// MARK: - Facebook Login
extension LoginViewController{
    func fetchFacebookFields(){
        
        LoginManager().logIn(permissions: ["email","public_profile"], from: nil) {
            [weak self](result, error) -> Void in
            
            guard let strongSelf = self else {
                return
            }
            
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
                        
                        strongSelf.loginUser = LoginUser(firstName: firstName, lastName: lastName, email: email, contactNumber: "",isVendor: strongSelf.isVendor)
                        if let url = URL(string: facebookProfileUrl) {
                            strongSelf.loginUser?.picture = url
                        }
                        
                        strongSelf.redirectUser(email: email)
                        
                    }
                }
            }
        }
    }
}

// MARK: - Google Login
extension LoginViewController{
    
    func getGoogleUser(){
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            let user = signInResult.user
            
            let emailAddress = user.profile?.email ?? ""
            
            let givenName = user.profile?.givenName ?? ""
            let familyName = user.profile?.familyName ?? ""
            
            let profilePicUrl = user.profile?.imageURL(withDimension: 320) ?? nil
            
            strongSelf.loginUser = LoginUser(firstName: givenName, lastName: familyName, email: emailAddress, contactNumber: "",isVendor: strongSelf.isVendor)
            strongSelf.loginUser?.picture = profilePicUrl
            strongSelf.redirectUser(email: emailAddress)
        }
    }
}

// MARK: - Apple Login
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
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
            self.loginUser = LoginUser(firstName: firstName, lastName: lastName, email: email, contactNumber: "",isVendor: self.isVendor)
            self.loginUser?.picture = nil
            self.redirectUser(email: email)
            break
        default:
            break
        }
    }
}


extension LoginViewController {
    func bioMetricVerification(){
        biometricIDAuth.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                return
            }
            
            biometricIDAuth.evaluate { [weak self] (success, error) in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard success else {
                    return
                }
                
                let loginUser =  UserDefaultsManager.shared.getUserData()
                strongSelf.loadDashBoard(user: loginUser)
                UIAlertViewExtention.shared.showBasicAlertView(title: "Success", message:  "You have a free pass, now", okActionTitle: "OK", view: strongSelf)
            }
        }
    }
}

extension LoginViewController {
    func openDashBoard(user : LoginUser?) {
        self.loadDashBoard(user: user)
    }
}
