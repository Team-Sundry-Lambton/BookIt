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
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    
    var imagePath : URL?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var isVendor = false
    var newUser = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile"
        addBorder()
        
        if let user = loginUser{
            newUser = true
            self.navigationItem.setHidesBackButton(true, animated: true)
            firstNameTxt.text = user.firstName
            lastNameTxt.text = user.lastName
            emailTxt.text = user.email
            phoneNumberTxt.text = user.contactNumber
            isVendor = user.isVendor
            if let path = user.picture{
                imagePath = path
                imageView.load(url: path)
            }
        }else{
            newUser = false
            let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = backBarButtonItem
            self.navigationItem.setHidesBackButton(false, animated: true)
            let user =  UserDefaultsManager.shared.getUserData()
            firstNameTxt.text = user.firstName
            lastNameTxt.text = user.lastName
            emailTxt.text = user.email
            phoneNumberTxt.text = user.contactNumber
            isVendor = user.isVendor
            if let path = user.picture{
                imagePath = path
                imageView.load(url: path)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    func addBorder() {
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 5
        imageView.layer.cornerRadius = imageView.frame.height / 2
    }
    
    @IBAction func changeProfilePicture() {
        addProfilePic()
    }
    @IBAction func saveProfileData() {
        
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
        }
        else
        {
            let loginUser = LoginUser(firstName: firstNameTxt.text ?? "", lastName: lastNameTxt.text ?? "", email: emailTxt.text ?? "", contactNumber: phoneNumberTxt.text ?? "",isVendor: isVendor)
            if (checkUserInDB(user: loginUser)){
                deleteUser(user: loginUser)
                saveUser()
                UserDefaultsManager.shared.saveUserData(user: loginUser)

                UIAlertViewExtention.shared.showBasicAlertView(title: "Success",message: "User updated successfully.", okActionTitle: "OK", view: self)
                
            }else{
                
                var picData : Data?
                do {
                    if let path = imagePath {
                        picData = try Data(contentsOf: path as URL)
                    }
                    
                } catch {
                    print("Unable to load data: \(error)")
                }
                if picData == nil {
                    picData = imageView.image?.pngData()
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
           
                saveUser()
                if newUser {
                    loadDashBoard(user: loginUser)
                }else{
                    if let navigator = self.navigationController {
                        navigator.popViewController(animated: true)
                    }else{
                        self.dismiss(animated: true)
                    }
                }
            }
        }
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
    
    func saveUser() {
        do {
            try context.save()
        } catch {
            print("Error saving the notes \(error.localizedDescription)")
        }
    }
    
    func deleteUser(user : LoginUser) {
        
        var entityName = "Client"
        if (isVendor){
            entityName = "Vendor"
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "email = %@ ", user.email)
        do {
            let user = try context.fetch(fetchRequest)
            if let slectedUser = user.first as? NSManagedObject {
                context.delete(slectedUser)
            }
        } catch {
            print(error)
        }
    }
    
    func loadDashBoard(user : LoginUser?){
        
        UserDefaultsManager.shared.setUserLogin(status: true)
        UserDefaultsManager.shared.setIsVendor(status: isVendor)
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        if let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController {
//            nextViewController.loginUser = user
//            self.navigationController?.pushViewController(nextViewController, animated: true)
////            self.present(nextViewController, animated:true, completion:nil)
//        }
        if let loginUser = user {
            UserDefaultsManager.shared.saveUserData(user: loginUser)
        }
        
 
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

            // if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController {
            //     if let navigator = navigationController {
            //         viewController.loginUser = user
            //         navigator.pushViewController(viewController, animated: true)
            //     }
            // }
        }
        
    }
    
    private func addProfilePic() {
        MediaManager.shared.pickMediaFile(title: "Choose Profile Picture",self) { [weak self] mediaObject in
            guard let strongSelf = self else {
                return
            }
            
            if let object = mediaObject {
                self?.imageView.image = object.image
                
                if let url = URL(string: object.fileName) {
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
