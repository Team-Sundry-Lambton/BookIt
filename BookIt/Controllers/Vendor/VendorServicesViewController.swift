//
//  VendorServicesViewController.swift
//  BookIt
//
//  Created by Malsha Parani on 2023-03-14.
//

import UIKit

class VendorServicesViewController: BaseViewController {

    var services = [Service]()
    var vendor : Vendor?
    
    @IBOutlet weak var noServiceImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getVendor()
        loadMyServices()
        tableView.reloadData()
    }
    
    func getVendor(){
        let user =  UserDefaultsManager.shared.getUserData()
        vendor = CoreDataManager.shared.getVendor(email: user.email)
    }
    
    func registerCell(){
        tableView.register(UINib.init(nibName: "VendorServiceListTableViewCell", bundle: nil), forCellReuseIdentifier: "VendorServiceListTableViewCell")
    }
    
    func loadMyServices(){
        services = CoreDataManager.shared.loadServicesByVendor(email: vendor?.email ?? "")
        
        if services.count > 0 {
            tableView.isHidden = false
            noServiceImage.isHidden = true
        } else {
            tableView.isHidden = true
            noServiceImage.isHidden = false
        }
    }
    
    func deleteService(service:Service){
        
    }
    
    @IBAction func addNewService(){
        if let viewController = UIStoryboard(name: "PostService", bundle: nil).instantiateViewController(withIdentifier: "PostServiceViewController") as? PostServiceViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
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

extension VendorServicesViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VendorServiceListTableViewCell", for: indexPath) as! VendorServiceListTableViewCell
        let service = services[indexPath.row]
        cell.configureCell(service: service)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = UIStoryboard(name: "ServiceDetail", bundle: nil).instantiateViewController(withIdentifier: "ClientServiceDetailViewController") as? ClientServiceDetailViewController {
            if let navigator = navigationController {
                let selectedService = services[indexPath.item]
                viewController.selectedService = selectedService
                navigator.pushViewController(viewController, animated: true)
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let DeleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
           
           let alert = UIAlertController(title: "Delete this service ", message: "Are you sure?", preferredStyle: .alert)
           let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
               
               //delete function
               self.deleteService(
                service: self.services[indexPath.row]
               )
               
           }
           
           let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
           alert.addAction(yesAction)
           alert.addAction(noAction)
           self.present(alert, animated: true, completion: nil)
           
           
       }
        
        let EditItem = UIContextualAction(style: .normal , title: "Edit") {  (contextualAction, view, boolValue) in
            
            //goto edit page
            if let viewController = UIStoryboard(name: "PostService", bundle: nil).instantiateViewController(withIdentifier: "PostServiceViewController") as? PostServiceViewController {
                if let navigator = self.navigationController {
                    let selectedService = self.services[indexPath.item]
                    viewController.selectedService = selectedService
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            
        }
       EditItem.backgroundColor = UIColor.systemBlue
        
       let swipeActions = UISwipeActionsConfiguration(actions: [DeleteItem,EditItem])

       return swipeActions
   }
    
    
    
    
}
