//
//  ClientBookVendorViewController.swift
//  BookIt
//
//  Created by Sonia Nain on 2023-03-22.
//

import UIKit

class ClientBookVendorViewController: UIViewController {
    
    var selectedService: Service?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        customDesign()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.isHidden = false
    }
    

    func customDesign(){
        let titleLabel = UILabel()
        if let service = selectedService{
            titleLabel.text = service.serviceTitle
        }
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }

}

