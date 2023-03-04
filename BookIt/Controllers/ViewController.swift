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
    
    @IBOutlet weak var appleLoginBtn: ASAuthorizationAppleIDButton!
    @IBOutlet weak var vendorStatus: UISwitch!{
        didSet{
            vendorStatus.onTintColor = UIColor(red: 61/255.0, green: 99/255.0, blue: 157/255.0, alpha: 0.7)
            vendorStatus.tintColor = UIColor(red: 61/255.0, green: 99/255.0, blue: 157/255.0, alpha: 0.7)
            vendorStatus.subviews[0].subviews[0].backgroundColor = UIColor(red: 61/255.0, green: 99/255.0, blue: 157/255.0, alpha: 0.7)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        appleLoginBtn.addTarget(self, action: #selector(handleLogInWithAppleID), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }

    @IBAction func continuGuest() {
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
      
    }
    
    func checkUserAvailablility(user : LoginUser){
        if (checkUserInDB(user: user)){
            loadDashBoard(user: user)
            
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! EditProfileViewController
            nextViewController.loginUser = user
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    func loadDashBoard(user : LoginUser?){
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "UserLogin")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
        nextViewController.loginUser = user
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    func checkUserInDB(user : LoginUser) -> Bool{
        var success = false
        var entityName = "Client"
        if (isVendor){
            entityName = "Vendor"
        }else{
            entityName = "Client"
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "email = %@ && contactNumber = %@", user.email, user.contactNumber)
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

            let fullName = user.profile?.name ?? ""
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
