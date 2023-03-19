//
//  VendorHomeViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-14.
//

import UIKit

class VendorHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var interfaceSegmented: CustomSegmentedControl! {
        didSet{
            interfaceSegmented.setButtonTitles(buttonTitles: ["Ongoing","History"])
            interfaceSegmented.selectorViewColor = #colorLiteral(red: 0.2415007949, green: 0.3881379962, blue: 0.6172356606, alpha: 1)
            interfaceSegmented.selectorTextColor = #colorLiteral(red: 0.2359043658, green: 0.3882460892, blue: 0.6172637939, alpha: 1)
            interfaceSegmented.textColor = #colorLiteral(red: 0.6947146058, green: 0.7548407912, blue: 0.8478365541, alpha: 1)
            interfaceSegmented.baseLineColor = #colorLiteral(red: 0.9490194917, green: 0.9490197301, blue: 0.9533253312, alpha: 1)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        interfaceSegmented.delegate = self
        tableView.register(UINib(nibName: "ServiceStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "ServiceStatusTableViewCell")
    }
}

extension VendorHomeViewController: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        
    }
}

extension VendorHomeViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceStatusTableViewCell", for: indexPath) as? ServiceStatusTableViewCell
        return cell ?? UITableViewCell()
    }
}

