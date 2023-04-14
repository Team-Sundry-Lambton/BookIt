//
//  NavigationBaseViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-31.
//

import UIKit
import CoreData
import JGProgressHUD

class NavigationBaseViewController: UIViewController {
    var loginUser : LoginUser?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedObjectContext: NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
        //MARK: dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
         view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.traitCollection.userInterfaceStyle == .dark {
            navigationController?.navigationBar.tintColor = UIColor.white
               } else {
                   navigationController?.navigationBar.tintColor = UIColor.black
               }
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
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
