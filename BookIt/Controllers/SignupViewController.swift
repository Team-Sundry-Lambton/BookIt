//
//  SignupViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-26.
//

import UIKit
import FacebookLogin
import CoreData
import GoogleSignIn
import AuthenticationServices
import JGProgressHUD

class SignupViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isVendor = false
    var loginUser : LoginUser?
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkMonitor.shared.setObserve(viewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = false
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
    
    @IBAction func register(sender: Any) {
        if firstNameTxt.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "First Name cannot be empty.",okActionTitle: "OK", view: self)
            return
        }
        else if lastNameTxt.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Last Name cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else if emailTxt.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Email cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else if phoneNumberTxt.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Contact number cannot be empty.", okActionTitle: "OK", view: self)
            return
        } else if passwordTxt.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Password cannot be empty.", okActionTitle: "OK", view: self)
            return
        } else if confirmPasswordTxt.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Confirm Password cannot be empty.", okActionTitle: "OK", view: self)
            return
        }else if confirmPasswordTxt.text != passwordTxt.text {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Password missmatch.", okActionTitle: "OK", view: self)
            return
        }
        else
        {
            loginUser = LoginUser(firstName: firstNameTxt.text ?? "", lastName: lastNameTxt.text ?? "", email: emailTxt.text ?? "", contactNumber: phoneNumberTxt.text ?? "",isVendor: isVendor)
            redirectUser(email:  emailTxt.text ?? "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    func redirectUser(email : String){
        if (checkUserAvailablility(email : email)){
            loadDashBoard()
            
        }else{
            if let user = loginUser {
                setUserObject(user: user)
            }
        }
    }
    func checkUserAvailablility(email : String) -> Bool{
        var dbCheck = false
        dbCheck = CoreDataManager.shared.checkUserInDB(email: email,isVendor: isVendor)
        if !dbCheck {
            LoadingHudManager.shared.showSimpleHUD(title: "Validating...", view: self.view)
            InitialDataDownloadManager.shared.chedkUserData(email: email ,isVendor: isVendor ){ status in
                DispatchQueue.main.async {
                    LoadingHudManager.shared.dissmissHud()
                    if let user = status {
                        if user{
                            dbCheck = true
                        }else{
                            dbCheck = false
                        }
                    }
                }
            }
        }
        return dbCheck
    }
    
    func setUserObject(user: LoginUser) {
        
        if (isVendor){
            let vendor = Vendor(context: context)
            vendor.firstName = user.firstName
            vendor.lastName =  user.lastName
            vendor.email = user.email
            vendor.picture = nil
            vendor.contactNumber = user.contactNumber
            vendor.bannerURL = nil
            vendor.password = passwordTxt.text
            saveUser()
     
                LoadingHudManager.shared.showSimpleHUD(title: "Inserting...", view: self.view)
                InitialDataDownloadManager.shared.addVendorData(vendor: vendor){ status in
                    DispatchQueue.main.async {
                        LoadingHudManager.shared.dissmissHud()
                        self.displayErrorMessage(status: status)
                    }
                }
        }else{
            let client = Client(context: context)
            client.firstName = user.firstName
            client.lastName = user.lastName
            client.email = user.email
            client.picture = nil
            client.contactNumber = user.contactNumber
            client.isPremium = false
            client.password = passwordTxt.text
            saveUser()
                LoadingHudManager.shared.showSimpleHUD(title: "Inserting...", view: self.view)
                InitialDataDownloadManager.shared.addClientData(client: client){ status in
                    DispatchQueue.main.async {
                        LoadingHudManager.shared.dissmissHud()
                        self.displayErrorMessage(status: status)
                    }
                }
        }
    }
    
    //MARK: - Core data interaction methods
    
    func saveUser() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
    func loadDashBoard(){
        
        UserDefaultsManager.shared.setUserLogin(status: true)
        UserDefaultsManager.shared.setIsVendor(status: isVendor)
        if let user = loginUser {
            UserDefaultsManager.shared.setUserLogin(status: true)
            UserDefaultsManager.shared.saveUserData(user: user)
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
    
    func displayErrorMessage(status : Bool?){
        if let status = status {
            if status == false {
                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
            }else{
                loadDashBoard()
            }
        }
    }
}



// MARK: - Facebook Login
extension SignupViewController{
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
                        
                        self.loginUser = LoginUser(firstName: firstName, lastName: lastName, email: email, contactNumber: "",isVendor: self.isVendor)
                        if let url = URL(string: facebookProfileUrl) {
                            self.loginUser?.picture = url
                        }
                        
                        self.redirectUser(email: email)
                        
                    }
                }
            }
        }
    }
}

// MARK: - Google Login
extension SignupViewController{
    
    func getGoogleUser(){
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            let user = signInResult.user
            
            let emailAddress = user.profile?.email ?? ""
            
            let givenName = user.profile?.givenName ?? ""
            let familyName = user.profile?.familyName ?? ""
            
            let profilePicUrl = user.profile?.imageURL(withDimension: 320) ?? nil
            
            self.loginUser = LoginUser(firstName: givenName, lastName: familyName, email: emailAddress, contactNumber: "",isVendor: self.isVendor)
            self.loginUser?.picture = profilePicUrl
            self.redirectUser(email: emailAddress)
        }
    }
}

// MARK: - Apple Login
extension SignupViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
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
