//
//  SignUpViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-02-28.
//

import UIKit
import CoreData

class EditProfileViewController: UIViewController {

    var loginUser : LoginUser?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var genderTxt: UITextField!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lblData: UILabel!
    
    var imagePath : URL?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = loginUser{
            firstNameTxt.text = user.firstName
            lastNameTxt.text = user.lastName
            emailTxt.text = user.email
            phoneNumberTxt.text = user.contactNumber
           
            if let path = user.picture{
                imagePath = path
                imageView.load(url: path)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupClicked() {
        
        if firstNameTxt.text == "" {
            displayAlert(message: "First Name cannot be empty.", title: "Error")
            return
        }
        else if lastNameTxt.text == "" {
            displayAlert(message: "Last Name cannot be empty.", title: "Error")
            return
        }
        else if emailTxt.text == "" {
            displayAlert(message: "Email cannot be empty.", title: "Error")
            return
        }
        else if phoneNumberTxt.text == "" {
            displayAlert(message: "Contact number cannot be empty.", title: "Error")
            return
        }
        else
        {
            var isVendor = false
            if let user = loginUser{
                isVendor = user.isVendor
            }
            var picData : Data?
            do {
                if let path = imagePath {
                    picData = try Data(contentsOf: path as URL)
                }
                } catch {
                    print("Unable to load data: \(error)")
                }
            
            if (isVendor){
                let vendor = Vendor(context: context)
                vendor.firstName = firstNameTxt.text
                vendor.lastName = lastNameTxt.text
                vendor.email = emailTxt.text
                vendor.picture = picData
                vendor.contactNumber = phoneNumberTxt.text
                vendor.bannerURL = nil
            }else{
                let client = Client(context: context)
                client.firstName = firstNameTxt.text
                client.lastName = lastNameTxt.text
                client.email = emailTxt.text
                client.picture = picData
                client.contactNumber = phoneNumberTxt.text
                client.isPremium = false
            }
            var loginUser = LoginUser(firstName: firstNameTxt.text ?? "", lastName: lastNameTxt.text ?? "", email: emailTxt.text ?? "", contactNumber: phoneNumberTxt.text ?? "",isVendor: isVendor)
            saveUser()
            loadDashBoard(user: loginUser)
        }
        
    }
    
    func saveUser() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
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
    
    func displayAlert(message: String, title : String){
        // create the alert
          let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

          // add an action (button)
          alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

          // show the alert
          self.present(alert, animated: true, completion: nil)
    }
    
    private func addProfileFic() {
        MediaManager.shared.pickMediaFile(self) { [weak self] mediaObject in
            guard let strongSelf = self else {
                return
            }
            
            if let object = mediaObject {
                self?.imageView.image = object.image
                
                if let url = URL(string: object.filePath) {
                    self?.imagePath = url
                }
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
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
