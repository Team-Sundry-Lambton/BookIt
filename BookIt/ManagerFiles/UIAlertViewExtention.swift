//
//  UIAlertViewExtention.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-05.
//

import UIKit

class UIAlertViewExtention: NSObject {
    
    static let shared = UIAlertViewExtention()
    
    func showBasicAlertView(title: String , message:String,okActionTitle: String, view: UIViewController){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: okActionTitle, style: UIAlertAction.Style.default, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }
}
