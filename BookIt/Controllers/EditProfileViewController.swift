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
    weak var delegate: ViewController!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    
//    var imagePath : URL?
    
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
               // imagePath = path
                imageView.downloaded(from: path)
            }
            emailTxt.isUserInteractionEnabled = true
            emailTxt.isEnabled = true
        }else{
            navigationController?.navigationBar.tintColor = UIColor.white
            
            if var textAttributes = navigationController?.navigationBar.titleTextAttributes {
                textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.white
                navigationController?.navigationBar.titleTextAttributes = textAttributes
            }
            self.title = "Edit Profile"
            emailTxt.isUserInteractionEnabled = false
            emailTxt.isEnabled = false
            self.navigationController?.navigationBar.isHidden = false
            newUser = false
            let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem = backBarButtonItem
            self.navigationItem.setHidesBackButton(false, animated: true)
            let user =  UserDefaultsManager.shared.getUserData()
            if(user.isVendor){
                getVendor()
            }else{
                getClient()
            }
           
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        if newUser {
//            delegate?.openDashBoard(user : loginUser)
//        }
    }
    
    func getClient(){
        let user =  UserDefaultsManager.shared.getUserData()
        if let user = CoreDataManager.shared.getClient(email: user.email){
            firstNameTxt.text = user.firstName
            lastNameTxt.text = user.lastName
            emailTxt.text = user.email
            phoneNumberTxt.text = user.contactNumber
            isVendor = false
            if let imageData = user.picture {
                self.imageView.image = UIImage(data: imageData)
            }
        }
    }
    
    func getVendor(){
        let user =  UserDefaultsManager.shared.getUserData()
        if let user = CoreDataManager.shared.getVendor(email: user.email){
            firstNameTxt.text = user.firstName
            lastNameTxt.text = user.lastName
            emailTxt.text = user.email
            phoneNumberTxt.text = user.contactNumber
            isVendor = true
            if let imageData = user.picture {
                self.imageView.image = UIImage(data: imageData)
            }
        }
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
            
            if (CoreDataManager.shared.checkUserInDB(email: loginUser.email,isVendor: isVendor)){
                    CoreDataManager.shared.deleteUser(user: loginUser,isVendor: isVendor)
                    UserDefaultsManager.shared.saveUserData(user: loginUser)
                    setUserObject(isEdit: true)
                    UIAlertViewExtention.shared.showBasicAlertView(title: "Success",message: "User updated successfully.", okActionTitle: "OK", view: self)
                    if let navigator = self.navigationController {
                        navigator.popViewController(animated: true)
                    }else{
                        self.dismiss(animated: true)
                    }

                }else{
                    UserDefaultsManager.shared.saveUserData(user: loginUser)
                        setUserObject(isEdit: false)
                    self.loginUser = loginUser
                            if let navigator = self.navigationController {
                                navigator.popViewController(animated: true)
                            }else{
                                self.dismiss(animated: true)
                            }
                }
        }
    }
    
    func setUserObject(isEdit : Bool) {
        var picData : Data?
//        do {
//            if let path = imagePath {
//                picData = try Data(contentsOf: path as URL)
//            }
//
//        } catch {
//            print("Unable to load data: \(error)")
//        }
        if picData == nil {
            picData = imageView.image?.jpeg(.lowest)
        }
        
        if (isVendor){
            let vendor = Vendor(context: context)
            vendor.firstName = firstNameTxt.text
            vendor.lastName = lastNameTxt.text
            vendor.email = emailTxt.text
            vendor.picture = picData
            vendor.contactNumber = phoneNumberTxt.text
            vendor.bannerURL = nil
            saveUser()
            if(isEdit){
                LoadingHudManager.shared.showSimpleHUD(title: "Updating...", view: self.view)
                InitialDataDownloadManager.shared.updateVendorData(vendor: vendor){ status in
                    DispatchQueue.main.async {
                        LoadingHudManager.shared.dissmissHud()
                        self.displayErrorMessage(status: status)
                    }
                }
            }else{
                LoadingHudManager.shared.showSimpleHUD(title: "Inserting...", view: self.view)
                InitialDataDownloadManager.shared.addVendorData(vendor: vendor){ status in
                    DispatchQueue.main.async {
                        LoadingHudManager.shared.dissmissHud()
                        self.displayErrorMessage(status: status)
                    }
                }
            }
        }else{
            let client = Client(context: context)
            client.firstName = firstNameTxt.text
            client.lastName = lastNameTxt.text
            client.email = emailTxt.text
            client.picture = picData
            client.contactNumber = phoneNumberTxt.text
            client.isPremium = false
            saveUser()
            if(isEdit){
                LoadingHudManager.shared.showSimpleHUD(title: "Updating...", view: self.view)
                InitialDataDownloadManager.shared.updateClientData(client: client){ status in
                    DispatchQueue.main.async {
                        LoadingHudManager.shared.dissmissHud()
                        self.displayErrorMessage(status: status)
                    }
                }
            }else{
                LoadingHudManager.shared.showSimpleHUD(title: "Inserting...", view: self.view)
                InitialDataDownloadManager.shared.addClientData(client: client){ status in
                    DispatchQueue.main.async {
                        LoadingHudManager.shared.dissmissHud()
                        self.displayErrorMessage(status: status)
                    }
                }
            }
        }
    }
    
    func displayErrorMessage(status : Bool?){
        if let status = status {
            if status == false {
                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
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
    
    private func addProfilePic() {
        MediaManager.shared.pickMediaFile(title: "Choose Profile Picture",self) { [weak self] mediaObject in
            guard let strongSelf = self else {
                return
            }
            
            if let object = mediaObject {
                self?.imageView.image = object.image
                
//                if let url = URL(string: object.fileName) {
//                    self?.imagePath = url
//                }
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
