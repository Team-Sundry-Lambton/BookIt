//
//  SignUpViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-02-28.
//

import UIKit
import CoreData

class SignUpViewController: UIViewController {

    var loginUser : LoginUser?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var genderTxt: UITextField!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lblData: UILabel!
    
    var imagePath = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = loginUser{
            firstNameTxt.text = user.firstName
            lastNameTxt.text = user.lastName
            emailTxt.text = user.email
            phoneNumberTxt.text = user.contactNumber
            genderTxt.text = user.gender
           
            if let path = user.picture{
                imagePath = path
                guard let url = URL(string: path) else { return }
             
                imageView.load(url: url)
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
            let client = Client(context: context)
            client.firstName = firstNameTxt.text
            client.lastName = lastNameTxt.text
            client.gender = genderTxt.text
            client.email = emailTxt.text
            client.picture = imagePath
            client.contactNumber = phoneNumberTxt.text
            
            saveUser()
        }
        
    }
    
    func saveUser() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
    func displayAlert(message: String, title : String){
        // create the alert
          let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

          // add an action (button)
          alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

          // show the alert
          self.present(alert, animated: true, completion: nil)
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
