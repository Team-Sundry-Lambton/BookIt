//
//  VendorBankAccountViewController.swift
//  BookIt
//
//  Created by Bao Trieu Thai on 2023-03-26.
//

import UIKit

class VendorBankAccountViewController: NavigationBaseViewController {

    @IBOutlet weak var txtRecipient: UITextField!
    @IBOutlet weak var txtRecipientName: UITextField!
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var txtTransitNumber: UITextField!
    @IBOutlet weak var txtInstitutionNumber: UITextField!
    @IBOutlet weak var btnAddToVerify: UIButton!
    
    var vendor: Vendor?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if var textAttributes = navigationController?.navigationBar.titleTextAttributes {
            textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        getBankAccount()
        // Do any additional setup after loading the view.
    }

    @IBAction func saveBankAccount(_ sender: Any) {
        if txtRecipient.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Recipient name cannot be empty.",okActionTitle: "OK", view: self)
            return
        }
        else if txtRecipientName.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Recipient Bank name cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else if txtAccountNumber.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Account number cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else if txtTransitNumber.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Transit number cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else if txtInstitutionNumber.text == "" {
            UIAlertViewExtention.shared.showBasicAlertView(title: "Error",message: "Institution number cannot be empty.", okActionTitle: "OK", view: self)
            return
        }
        else
        {
            setAccountObject()
        }
    }
    
    func setAccountObject() {
        let account = Account(context: context)
        let user =  UserDefaultsManager.shared.getUserData()
        account.recipiantName = txtRecipient.text
        account.recipiantBankName = txtRecipientName.text
        account.accountNumber = Int32(txtAccountNumber.text ?? "") ?? 0
        account.transitNumber = Int32(txtTransitNumber.text ?? "") ?? 0
        account.institutionNumber = Int32(txtInstitutionNumber.text ?? "") ?? 0
        
        let vendor = CoreDataManager.shared.getVendor(email: user.email)
        account.parent_vendor = vendor
        saveBankAccount()
        
        LoadingHudManager.shared.showSimpleHUD(title: "Inserting...", view: self.view)
        InitialDataDownloadManager.shared.addBankAccountData(account: account){ [weak self] status in
            DispatchQueue.main.async {
                LoadingHudManager.shared.dissmissHud()
                guard let strongSelf = self else {
                    return
                }
                strongSelf.displayErrorMessage(status: status)
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
            txtRecipient.text = account.recipiantName
            txtRecipientName.text = account.recipiantBankName
            txtAccountNumber.text = String(account.accountNumber)
            txtTransitNumber.text = String(account.transitNumber)
            txtInstitutionNumber.text = String(account.institutionNumber)
        }
    }
    
    func displayErrorMessage(status : Bool?){
        if let status = status {
            if status == false {
                UIAlertViewExtention.shared.showBasicAlertView(title: "Error", message:"Something went wrong please try again", okActionTitle: "OK", view: self)
            } else {
                UIAlertViewExtention.shared.showBasicAlertView(title: "Success",message: "Bank account inserted successfully.", okActionTitle: "OK", view: self)
                if let navigator = self.navigationController {
                    navigator.popViewController(animated: true)
                }else{
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
}
