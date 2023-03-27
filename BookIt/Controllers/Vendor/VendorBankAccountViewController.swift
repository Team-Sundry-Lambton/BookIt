//
//  VendorBankAccountViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-03-26.
//

import UIKit

class VendorBankAccountViewController: UIViewController {

    @IBOutlet weak var lblRecipient: UITextField!
    @IBOutlet weak var lblRecipientName: UITextField!
    @IBOutlet weak var lblAccountNumber: UITextField!
    @IBOutlet weak var lblTransitNumber: UITextField!
    @IBOutlet weak var lblInstitutionNumber: UITextField!
    @IBOutlet weak var btnAddToVerify: UIButton!
    
    var loginUser : LoginUser?
    var vendor: Vendor?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor.black
        
        if var textAttributes = navigationController?.navigationBar.titleTextAttributes {
            textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        getBankAccount()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    @IBAction func saveBankAccount(_ sender: Any) {
        if lblRecipient.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Recipient name cannot be empty.",okActionTitle: "OK", view: self)
            return
        }
        else if lblRecipientName.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Recipient Bank name cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else if lblAccountNumber.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Account number cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else if lblTransitNumber.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Transit number cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else if lblInstitutionNumber.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Institution number cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else
        {
            setUserObject(isEdit: false)
            UIAlertViewExtention.shared.showBasicAlertView(title: "Success",message: "Bank account updated successfully.", okActionTitle: "OK", view: self)
            if let navigator = self.navigationController {
                navigator.popViewController(animated: true)
            }else{
                self.dismiss(animated: true)
            }
        }
    }
    
    func setUserObject(isEdit : Bool) {
        let account = Account(context: context)
        let user =  UserDefaultsManager.shared.getUserData()
        account.recipiantName = lblRecipient.text
        account.recipiantBankName = lblRecipientName.text
        account.accountNumber = Int32(lblAccountNumber.text ?? "") ?? 0
        account.transitNumber = Int32(lblTransitNumber.text ?? "") ?? 0
        account.institutionNumber = Int32(lblInstitutionNumber.text ?? "") ?? 0
        
        let vendor = CoreDataManager.shared.getVendor(email: user.email)
        account.parent_vendor = vendor
        saveBankAccount()
        
        LoadingHudManager.shared.showSimpleHUD(title: "Inserting...", view: self.view)
        InitialDataDownloadManager.shared.addBankAccountData(account: account){ status in
            DispatchQueue.main.async {
                LoadingHudManager.shared.dissmissHud()
                self.displayErrorMessage(status: status)
            }
        }
    }
    
    //MARK: - Core data interaction methods
    
    func saveBankAccount() {
        do {
            try context.save()
        } catch {
            print("Error saving this account \(error.localizedDescription)")
        }
    }
    
    func getBankAccount(){
        let user =  UserDefaultsManager.shared.getUserData()
        if let account = CoreDataManager.shared.getVendorBankAccount(email: user.email){
            lblRecipient.text = account.recipiantName
            lblRecipientName.text = account.recipiantBankName
            lblAccountNumber.text = String(account.accountNumber)
            lblTransitNumber.text = String(account.transitNumber)
            lblInstitutionNumber.text = String(account.institutionNumber)
        }
    }
    
    func displayErrorMessage(status : Bool?){
        if let status = status {
            if status == false {
                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
            }
        }
    }
    
}
