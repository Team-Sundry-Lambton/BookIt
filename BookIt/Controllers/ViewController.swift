//
//  ViewController.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-02-27.
//

import UIKit
import FacebookLogin
import CoreData

class ViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let loginButton = FacebookManager.shared.addLoginButton()
//        loginButton.center = view.center
//        view.addSubview(loginButton)
//        NotificationCenter.default.addObserver(forName: .AccessTokenDidChange, object: nil, queue: OperationQueue.main) { (notification) in
//
//            // Print out access token
//            print("FB Access Token: \(String(describing: AccessToken.current?.tokenString))")
//
//            if (self.checkUserInDB()){
//
//            }else{
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
//                self.present(nextViewController, animated:true, completion:nil)
//            }
//        }
        
    }

    @IBAction func facebookLogin(_ sender: Any) {
        fetchFacebookFields();
    }
    
    override func viewWillAppear(_ animated: Bool) {
      
    }
}

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
                        
                          var loginUser = LoginUser(firstName: firstName, lastName: lastName, email: email, contactNumber: "")
                          loginUser.gender = ""
                          loginUser.picture = facebookProfileUrl
                          self.checkUserAvailablility(user: loginUser)
                          
                      }
                  }
              }
          }
      }
    
    func checkUserAvailablility(user : LoginUser){
        if (checkUserInDB(user: user)){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
            nextViewController.loginUser = user
            self.present(nextViewController, animated:true, completion:nil)
            
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            nextViewController.loginUser = user
            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    func checkUserInDB(user : LoginUser) -> Bool{
        var success = false
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Client")
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

